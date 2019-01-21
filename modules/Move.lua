--[[
{"move","transfer","trans"}
]]

return function (input,chests,inventory,tell,dynaStore)
  local function set(name, ... )
    local chestInfo = {...}
    local checks = #chestInfo
    local hits = {}
    for i = 1,#chestInfo do
      for o = 1,#chests do
        local cChest = chests[o]
        if cChest:find(chestInfo[i]) then
          if hits[cChest] == nil then
            hits[cChest] = {}
          end
          hits[cChest][i] = true
        end
      end
    end

    local maxHits = 0
    local found = false
    local similar = false
    for k,v in pairs(hits) do
      local flag = true
      for i = 1,checks do
        if not v[i] then
          flag = false
          break
        end
      end
      if flag then
        if found then
          similar = k
        else
          found = k
        end
      end
    end

    if similar then
      tell("Not enough information about the specified chest:")
      tell("Got too many results.")
    elseif not found then
      tell("No chest matched specifications.")
    elseif found and not similar then
      tell("Chest found:")
      tell(found)
      tell("Saved as '".. name .."'")
      dynaStore[name] = found
    else
      tell("Yeah this shouldn't happen at all...")
      tell("("..tostring(checks).." "..tostring(c)..")")
    end
  end

  local function remove(name)
    dynaStore[name] = nil
    tell("Removed "..name.." successfully.")
  end

  local function move(from,to,item,count,damage)
    local from2
    if dynaStore[to] then
      to = dynaStore[to]
    end
    if dynaStore[from] then
      from = dynaStore[from]
    end
    if to == "inventory" then
      to = inventory
    end
    if from == "inventory" then
      from = to
      to = inventory
    end
    local pushPullFlag = false
    local total = 0
    local function push(index)
      return from.pushItems(to,index,math.abs(math.ceil(count-total)))
    end
    local function pull(index)
      return to.pullItems(from,index,math.abs(math.ceil(count-total)))
    end
    if type(to) ~= "table" then
      from = peripheral.wrap(from)
      pushPullFlag = true
    end
    if pushPullFlag then
      if type(from) == "table" then
        local cInv = from.list()
        for i = 1,from.size() do
          if cInv[i] then
            if damage then
              if cInv[i].name:find(item) and cInv[i].damage == damage then
                total = total + push(i)
              end
            else
              if cInv[i].name:find(item) then
                total = total + push(i)
              end
            end
          end
          if total >= count then
            tell("Move operation successful")
            tell("Moved "..tostring(total).." items.")
            return
          end
        end
      else
        tell("Failed to wrap inventory "..tostring(from))
      end
      tell("Failed to move some items")
      tell("("..total.."/"..count.." items moved)")
    else
      if type(to) == "table" then
        local cInv = to.list()
        for i = 1,to.size() do
          if cInv[i] then
            if damage then
              if cInv[i].name:find(item) and cInv[i].damage == damage then
                total = total + pull(i)
              end
            else
              if cInv[i].name:find(item) then
                total = total + pull(i)
              end
            end
          end
          if total >= count then
            tell("Move operation successful")
            tell("Moved "..tostring(total).." items.")
            return
          end
        end
      else
        tell("Failed to wrap inventory "..tostring(from))
      end
      tell("Failed to move some items")
      tell("("..total.."/"..count.." items moved)")
    end
  end

  local function moveFromAll(to,item,count,damage)
    if dynaStore[to] then
      to = dynaStore[to]
    end
    local total = 0
    for i = 1,#chests do
      if chests[i] ~= to then
        total = total + move(chests[i],item,math.abs(math.ceil(count-total)),damage)
      end
      if total >= count then
        tell("Move operation successful")
        tell("Moved "..tostring(total).." items.")
        return
      end
    end
    tell("Failed to move all items")
    tell("("..total.."/"..count.." items moved)")
  end

  if input[2] == "set" then
    local name = input[3]
    set(name,table.unpack(input,4))
  elseif input[2] == "remove" then
    local name = input[3]
    if name ~= nil then
      remove(name)
    else
      tell("Expected name for argument 3")
    end
  else
    local item = input[5]
    local count = tonumber(input[6])
    if type(count) ~= "number" then
      count = string.lower(input[6])
      if count == "all" or count == "every" then
        count = 1000000
      else
        tell("Expected item-count for parameter 6.")
        return
      end
    end
    local damage = false
    if input[4] then
      damage = tonumber(input[7])
      if damage and type(damage) ~= "number" and string.lower(damage) ~= "nil" then tell("Expected damage value or nil as input 7") return end
    end
    if input[2] == "push" then
      move(input[3],input[4],item,count,damage)
    elseif input[2] == "pull" then
      move(input[4],input[3],item,count,damage)
    elseif input[2] == "moveall" then

    end
  end
end
