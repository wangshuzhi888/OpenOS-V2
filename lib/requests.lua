local internet=require("component").internet
local json=require("JSON")
local r={utils={}}
local responseObject={}
function responseObject:json()
  return json.decode(self.text)
end
function r.utils.decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function r.utils.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end
local function concatString(a,b)
  return a..b
end
function r.utils.parseCookies(cookies)
  if type(cookies)~="table" then
    return nil
  end
  cookiesStr=""
  for k,v in pairs(cookies) do
    cookiesStr=cookiesStr..tostring(k).."="..tostring(v)..";"
  end
  return cookiesStr
end
function r.get(URL,headers,cookies,stream)
  if type(headers)~="table" then
    headers={}
  end
  headers['cookie']=r.utils.parseCookies(cookies)
  local raw=internet.request(URL,nil,headers)
  local obj
  if not stream then
    raw.finishConnect()
    local status_code,status,headers=raw.response()
    local data,chunk="",""
    repeat
      chunk=raw.read(math.huge)
      if chunk then
        data=data..chunk
      end
    until not chunk
    obj=setmetatable(responseObject,{__index={raw=raw,text=data,stream=stream,url=URL,status_code=status_code,status=status,headers=headers}})
  else
    obj=setmetatable(responseObject,{__index={raw=raw,stream=stream,url=URL}})
  end
  return obj
end
return r
