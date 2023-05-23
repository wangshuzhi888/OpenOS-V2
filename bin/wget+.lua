local internet=require("component").internet
local computer=require("computer")
local fs=require("filesystem")
local args={...}
local resX,resY=require("component").gpu.getResolution()
function string.split(str, seperators)
  local t = {}
  for subst in string.gmatch(str, "[^"..seperators.."]+") do
    table.insert(t, subst)
  end
  return t
end
assert(type(args[1])=="string","please insert URL.")
local handle=internet.request(args[1],nil,{["User-Agent"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"})
assert(handle,"invaild URL.")
isFinished=false
counter=0
while not isFinished do
  isFinished,why=handle.finishConnect()
  if why then
    if why==args[1] then
      error("Server returned HTTP response code: 404 file not found for URL: "..args[1])
    else
      error(why)
    end
  end
  counter=counter+1
  if counter>99 then
    break
  end
end
local code,text,header=handle.response()
code=math.floor(code,1)
assert(code==200,"Server returned HTTP response code: "..tostring(code).." "..(text or "OK").." for URL: "..args[1])
print("code: "..tostring(code).." "..(text or "OK"))
if header["Content-Length"]==nil then
  Length=math.huge
else
  Length=tonumber(header["Content-Length"][1])
end
if header["Server"]==nil then
  Server="Unknow"
else
  Server=header["Server"][1]
end
print("Length: "..Length.." ("..math.floor(Length/1024,1).." KB)")
print("Server: "..Server)
filename=string.split(args[1],"/")
filename=filename[#filename]
if args[2] then
  filename=args[2]
end
local path=os.getenv("PWD")
if path=="/" then
    filename="/"..filename
else
    filename=path.."/"..filename
end
file=fs.open(filename,"w")
bytes=0
repeat
  data=handle.read(math.huge)
  computer.pullSignal(0)
  if data then
    bytes=bytes+#data
    file:write(data)
    a=math.floor(bytes/Length*100,1)
    if resX>117 then
      io.write("\rdownloading "..tostring(a).."%"..string.rep(" ",3-#tostring(a)).." ["..string.rep("█",a)..string.rep(" ",100-a).."]")
    else
      b=math.floor(a/5,1)
      io.write("\rdownloading "..tostring(a).."%"..string.rep(" ",3-#tostring(a)).." ["..string.rep("█",b)..string.rep(" ",20-b).."]")
    end
  end
until not data
handle.close()
file:close()
print("\nDone.")
