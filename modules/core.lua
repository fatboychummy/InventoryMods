--[[
{"get","grab","remove"}
The syntax of ALL module files: line 2: table of module arguments, line 5: start of return <function> statement.  Make sure this portion is commented or it will error.
]]
return function (input,chests,inventory,tell) --Functions will ALWAYS be passed these four values.
  input[3] = tonumber(input[3])
  local arg = input[1]
  local item = input[2]
  local count = input[3]
  local damage = input[4]
  if not damage then
    damage = false
  else
    damage = tonumber(damage)
  end
  --As the input still contains the first command argument, your "module" can contain multiple localized functions within this main function
  --useful if your module has a "get" and "remove", like this module does.
  local function get()
    if type(count) ~= "number" then
      tell("Expected an item count for argument #3")
    end
    if type(damage) ~= "number" and type(damage) ~= "boolean" then
      tell("Expected damage value or nil for argument #4")
    end
    local pushed = 0
    for i = 1,#chests do                      --For each chest...
      local cur = peripheral.wrap(chests[i])  --wrap current chest for search...
      if cur then                             --Sometimes errors if you dont do this.
        local cInv = cur.list()               --Lists the items in chests in a way readable by CC
        for o = 1,cur.size() do              --For every slot in the chest...
          if cInv[o] then                     --If there is an item in slot o...
            if damage then
              if cInv[o].name:find(item) and cInv[o].damage == damage then --input 2 is the name of the item to find...
                pushed = pushed + inventory.pullItems(chests[i],o,count)      --push the items and keep track of how many items were pushed
                if pushed >= count then                                       --if we've pushed how many was wanted we stop.
                  return
                end
              end
            else
              if cInv[o].name:find(item) then --input 2 is the name of the item to find...
                pushed = pushed + inventory.pullItems(chests[i],o,count)
                if pushed >= count then
                  return
                end
              end
            end
          end
        end
      end
    end
  end
  local function remove()

  end

  --the below statement will iterate through the first argument and run whatever is needed.
  if input[1] == "get" or input[1] == "grab" then
    get()
  elseif input[1] == "remove" then
    grab()
  else
    tell("This module has no parameter, "..input[1])
  end
end
