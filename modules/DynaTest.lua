--[[
{"test"}
]]

return function (input,chests,inventory,tell,dynaStore)
  if input[2] == "print" then
    tell("Current contents of dyna:")
    for i = 1,#dynaStore do
      tell(dynaStore[i])
    end
  elseif input[2] == "store" then
    tell("Storing "..input[3])
    dynaStore[#dynaStore+1] = input[3]
  end
end
