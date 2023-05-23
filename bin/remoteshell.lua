count=10
timeout=5
speed=0.1
event=require("event")
m=require("component").modem
resX,resY=require("component").gpu.getResolution()
gpu=require("component").gpu
tty=require("tty")
tty.clear()
m.open(22)
servers={}
function server(_,_,from,_,d,msg)
	if d == nil then 
		gpu.set(resX-3,1,"---")
	else 
		gpu.set(resX-3,1,math.floor(d,1))
	end
	if msg == "givemeadatapack" then
		m.broadcast(22,"DATAPACK")
	elseif msg == "ping" then
        m.send(from,22,"pong")
    else 
		a=io.popen(msg)
		run=true
		while run do
			data=a:read()
			if data == nil then
				m.send(from,22,"done")
				run=false
			else
				m.send(from,22,data)
			end
		end
	end
end
function ping()
    m.send(server,22,"ping")
    msg=table.pack(event.pull(timeout,"modem"))[6]
    if msg == nil then
        print("Connection lost: Timed out")
		event.cancel(eid)
        return 
    end  
end 
io.write("OC-Remote Shell\n1.服务端\n2.客户端\n")
s=io.read()
if s == "1" then
	event.listen("modem_message",server)
end
if s == "2" then
	m.broadcast(22,"givemeadatapack")
	for i=1,count do 
		_,_,from,_,_,msg=event.pull(1,"modem")
    	resX_=resX-13
    	a=math.floor((i/count)*resX_,1)
    	io.write("\rScaning... ["..string.rep("█",a)..string.rep(" ",(resX_)-a).."]")
		if msg == "DATAPACK" then
		 table.insert(servers,from)
		end
	end
    if #servers==0 then print("No server found.") return end
	for i=1,#servers do 
		print(tostring(i).."."..servers[i])
	end
	server=servers[tonumber(io.read()) or 1]
    eid=event.timer(60,ping,1/0)
	while true do 
		io.write("\n>")
		cmd=io.read()
		if cmd == "shutdown" or cmd == "reboot" then
			print("Connection lost.")
            event.cancel(eid)
			break
		elseif cmd=="dc" then 
            event.cancel(eid)
			break
		end
		m.send(server,22,cmd)
		run=true
		while run do
			_,_,_,_,d,msg=event.pull(timeout,"modem")
			if d == nil then 
				gpu.set(resX-3,1,"---")
			else 
				gpu.set(resX-3,1,math.floor(d,1))
			end
			if msg == "done" then
				run=false
			elseif msg==nil then 
				print("Connection lost: Timed out")
				event.cancel(eid)
				return 
			else 
				print(msg)
			end
		end
	end
end
