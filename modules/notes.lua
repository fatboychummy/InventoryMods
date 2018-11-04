--[[
{"notes","note"}
]]

return function (input,_,_,tell,dynaStore)
  if input[2] == "read" then
    tell("Current notes:")
    if #dynaStore == 0 then
      tell("None")
    end
    for i = 1,#dynaStore do
      tell(tostring(i)..": "..dynaStore[i])
    end
  elseif input[2] == "write" then
    local str = ""
    for i = 3,#input do
      str = str..input[i].. " "
    end
    str = str:sub(1,str:len()-1)
    tell("saving '"..str.."'")
    dynaStore[#dynaStore+1] = str
  elseif input[2] == "remove" then
    input[3] = tonumber(input[3])
    if type(input[3]) ~= "number" then
      tell("Expected index as third argument.")
      return
    end
    table.remove(dynaStore,input[3])
    tell("Removed note "..tostring(input[3]))
  end
end
