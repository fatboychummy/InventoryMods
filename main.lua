--[[
  0.01
  Started a new thing!
]]


local version = 0.01
local modules = {}
local modulesLocation = "/modules/"
local chests = {}
local manip = false
local manipFuncs = {}
local customFileName = "customization"
local custom = fs.exists(customFileName)

local function copy(a,b)
  assert(type(a) == "table","copy: first input is not a table.")
  for k,v in pairs(a) do
    if type(v) == "table" then
      b[k] = {}
      copy(a[k],b[k])
    else
      b[k] = v
    end
  end
end

local function ao(wrt,h)
  h.writeLine(wrt)
end

local function writeCustomization(file)
  local h = fs.open(file,"w")
  ao("return {",h)
  ao("  preferredDumpChest = false,",h)
  ao("  manipulators = {},",h)
  ao("  preferredDetectionMethod = \"command\", --The event created by whatever chat recorder you are using.  It is seriously recommended you don't change this.",h)
  ao("  prefix = \"i\",",h)
  ao("}",h)
  h.flush()
  h.close()
end

local function moveCustomization(a)
  printError("Warning: Customization file error, moving it to a new location then creating another customization file.")
  local b = a:find(":")
  local c = a:sub(b+1)
  local d = c:match("%d+")
  print("This program will mark the line (line "..d..") with a comment.")
  d = tonumber(d)
  assert(type(d) == "number","This should not happen. Please send a signal flare to fatboychummy")
  local fileName = "BAD-"..customFileName
  local h1 = fs.open(customFileName,"r")
  local h2 = fs.open(fileName,"w")
  local i = 1
  local cur = h1.readLine()
  while cur do
    if i == d then
      cur = cur.."--"..string.rep("!",15)
    end
    h2.writeLine(cur)
    cur = h1.readLine()
    i = i + 1
  end
  h1.close()
  h2.close()
  print("File moved")
  fs.delete(customFileName)
  writeCustomization(customFileName)
  print("All done")
end



local function setup()
  writeCustomization(customFileName)
end

if not custom then
  setup()
  print("System is set up.")
  return 0
else
  ok,custom = pcall(dofile,customFileName)
  if not ok or not custom or custom == {} then
    moveCustomization(custom)
    return 0
  end
  custom.modules = {}
end


do
  local tmods = fs.list(modulesLocation)
  for i = 1,#tmods do
    local h = fs.open(modulesLocation..tmods[i],"r")
    h.readLine()
    local no = h.readLine()
    h.close()
    custom.modules[tmods[i]] = textutils.unserialize(no)
  end
end


local function getChests()
  local a = peripheral.getNames()
  chests = {}
  for i = 1,#a do
    if a[i]:find("chest") or a[i]:find("shulker") then
      chests[#chests+1] = a[i]
    end
  end
end

local tofind = {
  "getEnder",
  "tell",
  "getName",
  "getInventory",
}

assert(#custom.manipulators ~= 0,"Manipulators table is empty.")

for i = 1,#custom.manipulators do
  local c = custom.manipulators[i]
  local cur = peripheral.wrap(c)
  if cur then
    for o = 1,#tofind do
      if not manipFuncs[tofind[o]] and cur[tofind[o]] then
        manipFuncs[tofind[o]] = cur[tofind[o]]
        print("Found",tofind[o])
      end
    end
  else
    printError("Warning: Peripheral "..c.." does not exist.")
  end
end
for i = 1,#tofind do
  if manipFuncs[tofind[i]] == nil then
    error("Failed to find the function:",tofind[i].."...  Make sure the proper modules are installed.")
  end
end

local name = manipFuncs.getName()
local inv = manipFuncs.getInventory()
local ender = manipFuncs.getEnder()

local mods = {}
copy(custom.modules,mods)
print(textutils.serialise(mods))

local function parseModules(str)
  for k,v in pairs(mods) do
    print("Checking module:",k)
    for i = 1,#v do
      if str == v[i] then
        return k,v
      end
    end
  end
  return false
end


local function runModule(mod,tab)
  getChests()
  local a = dofile(modulesLocation..mod)
  a(tab,chests,inv,manipFuncs.tell)
end


local function parse(tab)
  print("Parsing...")
  for i = 1,#tab do
    tab[i] = tab[i]:lower()
  end
  local module = parseModules(tab[1])
  print("parsed:",tab[1]..", got",module)
  if module then
    runModule(module,tab)
  else
    print("Module does not exist!")
  end
end


local function main()
  while true do
    local ev = {os.pullEvent(custom.preferredDetectionMethod)}
    if ev[2] == name then
      if ev[3] == custom.prefix then
        parse(ev[4])
      end
    end
    print("---")
  end
end




--TODO: Pcall main and handle errors.
main()