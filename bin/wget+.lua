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
