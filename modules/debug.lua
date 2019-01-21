--[[
{"debug"}
]]

return function (input,chests,inventory,tell,dynaStore,mods,chestCache,allItems)
  local function cSerialize(tb,spc)
    spc = spc or 0
    local i = 1
    local tmp = {}
    if spc == 0 then
      tmp[1] = string.rep(" ",spc) .. "{"
    else
      i = i - 1
    end
    spc = spc + 2
    if type(tb) == "table" then
      for k,v in pairs(tb) do
        i = i + 1
        if type(v) == "table" then
          local tmp2 = cSerialize(v,spc+2)
          tmp[i] = string.rep(" ",spc) .. "[\"" .. k .. "\"] = {"
          i = i + 1
          for o = 1,#tmp2 do
            tmp[i] = tmp2[o]
            i = i + 1
          end
          tmp[i] = string.rep(" ",spc) .. "}"
        elseif type(v) == "string" then
          tmp[i] = string.rep(" ",spc) .. "[\"" .. k .. "\"] = \"" .. v .. "\""
        elseif type(v) == "char" then
          tmp[i] = string.rep(" ",spc) .. "[\"" .. k .. "\"] = \'" .. v .. "\'"
        elseif type(v) == "function" then
          tmp[i] = string.rep(" ",spc) .. "[\"" .. k .. "\"] = FUNCTION"
        elseif type(v) == "thread" then
          tmp[i] = string.rep(" ",spc) .. "[\"" .. k .. "\"] = COROUTINE"
        else
          tmp[i] = string.rep(" ",spc) .. "[\"" .. k .. "\"] = " .. v
        end
      end
    else
      return tostring(tb)
    end
    spc = spc - 2
    if spc == 0 then
      tmp[#tmp+1] = string.rep(" ",spc) .. "}"
    end
    return tmp
  end

  if input[2] == "dyna" then
    if input[3] ~= nil then
      if dynaStore[input[3]] then
        tell("Contents of dynaStore for module " .. input[3] .. ":")
        local t = cSerialize(dynaStore[input[3]])
        for i = 1,#t do
          tell(t[i])
        end
      else
        tell("No data in dynaStore for mod " .. tostring(input[3]) .. ":")
      end
    else
      tell("Contents of whole dynaStore: ")
      local t = cSerialize(dynaStore)
      for i = 1,#t do
        tell(t[i])
      end
    end
  elseif input[2] == "get" then
    if input[3] == "modules" then
      tell("These are the connected modules, and the commands to activate them.")
      local t = cSerialize(mods)
      for i = 1,#t do
        tell(t[i])
      end
    elseif input[3] == "itemcache" then
      local count = 0
      local count2 = 0
      local itms = {}
      for k, v in pairs(allItems) do
        for k2, v2 in pairs(v) do
          count2 = count2 + 1
          count = v2.count + count
          itms[v2.Display] = v2.count
        end
      end
      tell("There is a total of " .. tostring(count) .. " items stored currently.")
      tell("There are " .. count2 .." unique items.")
      if input[4] and input[4] == "detailed" then
        tell("This may take a while...")
        for k,v in pairs(itms) do
          tell(k .. ": " .. v)
        end
      end
    elseif input[3] == "chestcache" then

    else
      tell("I do not understand wat de faq u want u dum shit")
    end
  elseif input[2] == "repeat" then
    tell("\\. "..table.concat(input," "))
  else
    tell("No debug: "..tostring(input[2]))
  end

end
