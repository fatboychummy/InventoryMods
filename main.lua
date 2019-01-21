--[[
  0.01
  [re]Started a new thing!
]]

local dataLocation = false        -- Location of data, defaults to "/data/"
local modulesLocation = false     -- Location of modules, defaults to "/data/modules/"
local customFileName = false      -- Location of 'customization' file, defaults to "/data/custom.modu"
local dynaName = false            -- Location of DynaStore, defaults to "/data/dyna.modu"
local manipulatorOverride = false -- [Not currently working!]If you require a specific manipulator, change this value to the name of the manipulator on the network

local version = 001               -- Version number
local chests = {}                 -- All chest names stored in a table.
local allitems = {}               -- All items stored in a table (fast cache :tm:).
local chestCache = {}             -- NOT REQUIRED, DELET DELET DELET?
local modules = {}                -- Modules, stored as a table.
local manipFuncs = {}             -- Manipulator functions returned

local dynaStore = false           -- DynaStore data
local manip = false               -- manipulator confusion DELET?
local custom = false              -- customization DELET?
local running = false             -- DELET?

local functionsNeeded = {
  manipulator = {
    "tell",
    "getInventory",
    "getEnder",
    "getName",
    "capture",
    "clearCaptures",
  }
}



local function dCopy(a,b)
  --DeepCopy
  assert(type(a) == "table","copy: first input is not a table.")
  for k,v in pairs(a) do
    if type(v) == "table" then
      b[k] = {}--If table, recursive copy
      dCopy(a[k],b[k])
    else
      b[k] = v
    end
  end
end

local function tell(stuff)
  local lines = {}
  if stuff:len() > 100 then
    local o = 1
    for i = 1,stuff:len(),100 do
      lines[o] = stuff:sub(i,i+99)
      o = o + 1
    end
  else
    lines[1] = stuff
  end
  for i = 1,#lines do
    local a,b = pcall(manipFuncs.tell,lines[i])
    if not a then
      printError("Your chat-recorder is either missing or not bound properly.")
      term.setTextColor(colors.yellow)
      print(b)
      term.setTextColor(colors.white)
    end
  end
end

local function doErr(func,cont)
  local err = "ERR:" .. tostring(func) .. ": " .. tostring(cont)
  tell(err)
  error(err)
end

local function overWriteMain(variable,equals)
  --Checks for instances of "local" as first word
  --on a line.  If so, checks variable
  --if == variable, update it to be equal to
  -- "equals"
  --Assumes only major variables (variables at 'root' level)
  local declaration = "local " .. variable
  local find = "^" .. declaration
  local h = fs.open(shell.getRunningProgram(),"r")
  --If open...
  if h then

    --load lines of program into data
    local data = {}
    local line = h.readLine()
    local o = 0
    repeat
      o = o + 1
      data[o] = line
      line = h.readLine()
    until not line
    h.close()



    --search through the data for the variable.
    o = -1 --if o == -1 after searching, failed.
    for i = 1,#data do
      if data[i]:match("^local ") then
        local a = data[i]:gmatch("%w+")
        a()
        local var = a()
        a = nil
        --if the variable we found is named "variable" then
        if var == variable then
          -- we found our variable
          o = i
          break
        end
      end
    end
    if o == -1 then
      doErr("overWriteMain","Failed to find variable " .. tostring(variable))
      return false
    else
      declaration = declaration .. " = "
      if type(equals) == "string" then
        declaration = declaration .. "\"" .. equals .. "\""
      elseif type(equals) == "table" then
        declaration = declaration .. textutils.serialize(equals)
      elseif type(equals) == "number" or type(equals) == "boolean" then
        declaration = declaration .. tostring(equals)
      else
        doErr("overWriteMain","Unsupported type (" .. type(equals) .. ")")
        return false
      end
      data[o] = declaration
      local h = fs.open(shell.getRunningProgram(),"w")
      if h then
        for i = 1,#data do
          h.writeLine(data[i])
        end
        h.close()
        return true
      else
        doErr("overWriteMain","No handle (2)")
        return false
      end
    end
  else
    doErr("overWriteMain","No handle (1).")
    return false
  end
end

--[[
local dataLocation = false
local modulesLocation = false
local customFileName = false
local dynaName = false
local chestSaveName = false

local dynaStore = false
local manip = false
local custom = false
local running = false
]]


--Check if the setup is valid (Function will overwrite variables for faster startup times.)
local function checkSetup()
  -----------------------------this boio checks variables and updates them.
  local function check()
    local f = true
    if dataLocation then
      print("Data Location is specified, checking.")
      if type(dataLocation) == "string" then
        assert(dataLocation:match("^/.+/$"),"Cannot run; variable dataLocation: expected absolute path to folder. (Must start and end in '/').")
        print("dataLocation is valid.")
      else
        doErr("checkSetup","Cannot run; variable dataLocation is of incorrect type.")
      end
    else
      f = false
      print("dataLocation is false.")
      overWriteMain("dataLocation","/data/")
      print("updated")
    end
    if modulesLocation then
      if type(modulesLocation) == "string" then
        assert(modulesLocation:match("^/.+/$"),"Cannot run; variable modulesLocation: expected absolute path to folder. (Must start and end in '/').")
        print("modulesLocation is valid.")
      else
        doErr("checkSetup","Cannot run; variable modulesLocation is of incorrect type.")
      end
    else
      f = false
      print("modulesLocation is false.")
      overWriteMain("modulesLocation","/data/modules/")
      print("updated")
    end
    if customFileName then
      if type(customFileName) == "string" then
        assert(customFileName:match("^/.+%.modu$"),"Cannot run; variable customFileName: expected absolute path to file, ending with file-extension '.modu'.")
        print("customFileName is valid.")
      else
        doErr("checkSetup","Cannot run; variable customFileName is of incorrect type.")
      end
    else
      f = false
      print("customFileName is false.")
      overWriteMain("customFileName","/data/custom.modu")
      print("updated")
    end
    if dynaName then
      if type(dynaName) == "string" then
        assert(dynaName:match("^.+%.modu$"),"Cannot run; variable dynaName:")
        print("dynaName is valid.")
      else
        doErr("checkSetup","Cannot run; variable dynaName is of incorrect type.")
      end
    else
      f = false
      print("dynaName is false.")
      overWriteMain("dynaName","/data/dyna.modu")
      print("updated")
    end

    return f
  end

  --Start this stuff...
  local vars = {"dataLocation","modulesLocation","customFileName","dynaName"}
  if not dataLocation or not modulesLocation or not customFileName or not dynaName then
    print("Setup is invalid (First run?)")
    check()
    print("Setup should be valid.  Rebooting.")
    os.sleep(3)
    os.reboot()
  else
    if not check() then
      print("Setup was invalid, rebooting now.")
    end
    print("Setup is valid.")
  end
end

local function findFunctionsInPeripherals(ttab)
  local tab = dCopy(ttab,tab)

  --[[
    {
      peripheralType = {
        "peripheralFunc1",
        "peripheralFunc2",
        overridePeripheral = "peripheralFunc5",
      },
      peripheralType2 = {
        "peripheralFunc3",
        "peripheralFunc4",
      }
    }
  ]]
  local perip = {}


  local function getPeriphs(tp)
    local all = peripheral.getNames()
    local perips = {}
    for i = 1,#all do
      if all[i]:find(tp) then
        perips[#perips+1] = peripheral.wrap(all[i])
      end
    end
    return perips
  end

  for k,v in pairs(tab) do
    --[[
      each k: peripheralType
      each v: table of peripheralFuncs
    ]]
    assert(type(v) == "table","ERR:findFunctionsInPeripherals: Expected table, index " .. tostring(k))
    local pers = getPeriphs(k)
    if pers then
      for k2,v2 in pairs(v) do
        --[[
          each k2: number index or string override
          each v2: peripheralFunctionName
        ]]
        local grabbed = false
        if type(k2) == "number" then
          --No override
          for i = 1,#pers do
            --[[
              each i: peripheral of type k
            ]]
            for k3,v3 in pairs(pers[i]) do
              --[[
                each k3: peripheralFunctionName of peripheral of type k
                each v3: peripheralFunction of peripheral of type k
              ]]
              if k3 == v2 then
                perip[k3] = v3
                tab[k][k2] = nil
                grabbed = true
                break
              end
            end
            if grabbed then break end
          end
        elseif type(k2) == "string" then
          --Override
          if peripheral.isPresent(k2) then
            local ps = peripheral.wrap(k2)
            for k3,v3 in pairs(ps) do
              --[[
                each k3: peripheralFunctionName of peripheral of type k
                each v3: peripheralFunction of peripheral of type k
              ]]
              if k3 == v2 then
                perip[k3] = v3
                tab[k][k2] = nil
                break
              end
            end
          end
        else
          doErr("findFunctionsInPeripherals","Unexpected error ID 1")
        end
      end
    end
  end

  for k,v in pairs(tab) do
    local notThere = true
    for k2,v2 in pairs(v) do
      notThere = false
      break
    end
    if notThere then
      tab[k] = nil
    end
  end

  return perip,tab
end

local function saveDyna()
  local h = fs.open(dataLocation..dynaName,"w")
  if h then
    h.write(textutils.serialize(dynaStore))
    h.close()
  end
end

local function loadDyna()
  local h = fs.open(dataLocation..dynaName,"r")
  if h then
    dynaStore = textutils.unserialize(h.readAll())
    h.close()
  else
    dynaStore = false
  end
end

local function prepareDyna()
  loadDyna()
  if not dynaStore then loadDyna() end
  if not dynaStore then dynaStore = {} end
  local tmods = fs.list(modulesLocation)
  for i = 1,#tmods do
    local h = fs.open(modulesLocation..tmods[i],"r")
    h.readLine()
    local no = h.readLine()
    h.close()
    custom.modules[tmods[i]] = textutils.unserialize(no)
    if not dynaStore[tmods[i]] then
      dynaStore[tmods[i]] = {}
    end
  end
end




return 1
