local component=require("component")
local event=require("event")
local modem=component.modem
local DNS={}

modem.open(53)

function DNS.get(name)
	modem.broadcast(53,"GET "..name.." HTTP/1.1")
	local _,_,form1,port,_,message=event.pull(5,"modem")
	if not message then return nil end
	if message == "HTTP/1.1 200 OK" and port == 53 then
		local _,_,form2,port,_,message=event.pull(5,"modem")
		if port == 53 and form1 == form2 then
			return message
		else
			return nil
		end
	else
		return nil
	end
end

function DNS.reg(name)
	modem.broadcast(53,"REG "..name.." HTTP/1.1")
	local _,_,form1,port,_,message=event.pull(5,"modem")
	if not message then return false end
	if message == "HTTP/1.1 201 Created" and port == 53 then
		return true
	else
		return false
	end
end

function DNS.del(name)
	modem.broadcast(53,"DEL "..name.." HTTP/1.1")
	local _,_,form1,port,_,message=event.pull(5,"modem")
	if not message then return false end
	if message == "HTTP/1.1 204 No Content" and port == 53 then
		return true
	else
		return false
	end
end

return DNS
