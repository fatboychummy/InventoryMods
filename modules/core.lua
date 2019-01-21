--[[
{"get","grab","remove"}
The syntax of ALL module files: line 2: table of module arguments, line 5: start of return <function> statement.  Make sure this portion is commented or it will error.
]]
return function (input,chests,inventory,tell) --Functions will ALWAYS be passed these four values.
  local arg = input[1]
  local item = input[2]
  local count = tonumber(input[3])
  local damage = input[4]
  if not damage then
    damage = false
  else
    damage = tonumber(damage)
  end
  --As the input still contains the first command argument, your "module" can contain multiple localized functions within this main function
  --useful if your module has a "get" and "remove", like this module does.

  if input[3] == "all" or input[3] == "every" then
    count = 100000
  end
  if type(count) ~= "number" then
    tell("Expected an item count for argument #3")
    return 0
  elseif count <= 0 then
    tell("Expected an item count greater than 0 for argument #3")
    return 0
  end
  if type(damage) ~= "number" and type(damage) ~= "boolean" then
    tell("Expected damage value or nil for argument #4")
    return 0
  end

  local function get()
    local pushed = 0
    for i = 1,#chests do                      --For each chest...
      local cur = peripheral.wrap(chests[i])  --wrap current chest for search...
      if cur then                             --Sometimes errors if you dont do this.
        local cInv = cur.list()               --Lists the items in chests in a way readable by CC
        for o = 1,cur.size() do              --For every slot in the chest...
          if cInv[o] then                     --If there is an item in slot o...
            if damage then

              if cInv[o].name:find(item) and cInv[o].damage == damage then --input 2 is the name of the item to find...
                local tomove = math.abs(count-pushed)
                tell("Attempting to push "..tostring(tomove).." items.")
                pushed = pushed + inventory.pullItems(chests[i],o,tomove)      --push the items and keep track of how many items were pushed
                if pushed >= count then                                       --if we've pushed how many was wanted we stop.
                  tell("Sent "..tostring(pushed).."/"..tostring(count).." items.")
                  return
                end
              end
            else
              if cInv[o].name:find(item) then --input 2 is the name of the item to find...
                local tomove = math.abs(count-pushed)
                tell("Attempting to push "..tostring(tomove).." items.")
                pushed = pushed + inventory.pullItems(chests[i],o,tomove)
                if pushed >= count then
                  tell("Sent "..tostring(pushed).."/"..tostring(count).." items.")
                  return
                end
              end
            end
          end
        end
      end
    end
    tell("Sent "..tostring(pushed).."/"..tostring(count).." items.")
  end
  local function remove()
    local lastEmpty = false  --Something for speedup
    local function push(count,index) --push items from inventory to chest
      if lastEmpty then --if we've cached the last empty chest...
        for i = lastEmpty,#chests do
          for i = 1,#chests do
            local a = inventory.pushItems(chests[i],count,index)
            if a and a > 0 then
              lastEmpty = i
              return a
            end
          end
          return 0
        end
      else--if we don't know the last empty chest...
        for i = 1,#chests do
          local a = inventory.pushItems(chests[i],count,index)
          if a and a > 0 then
            lastEmpty = i
            return a
          end
        end
        return 0
      end
    end
    local pushed = 0
    local cInv = inventory.list()
    for i = 1,inventory.size() do
      if cInv[i] then
        local c = cInv[i].name
        local d = cInv[i].damage
        if c:find(item) then
          local tomove = math.abs(count-pushed)
          if damage and damage == d then
            tell("Attempting to push "..tostring(tomove).." items.")
            pushed = pushed + push(i,tomove)
          elseif not damage then
            tell("Attempting to push "..tostring(tomove).." items.")
            pushed = pushed + push(i,tomove)
          end
        end
      end
    end
    tell("Pushed "..tostring(pushed).."/"..tostring(count).." items.")
  end

  --the below statement will iterate through the first argument and run whatever is needed.
  if input[1] == "get" or input[1] == "grab" then
    get()
  elseif input[1] == "remove" then
    remove()
  else
    tell("This module has no parameter, "..input[1])
  end
end
