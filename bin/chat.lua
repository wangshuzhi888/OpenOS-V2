local event=require("event")
local component=require("component")
local tunnel = component.tunnel
local gpu = component.gpu
local resX,resY=gpu.getResolution()
local term=require("term")

if not tunnel then
	error("Please insert your tunnel card.")
end

print("Press any key to start.")
local name=({event.pull("key_down")})[5]

function process_message(_,_,_,_,_,remotename,remotemessage)
	length=#remotename+#remotemessage+1
	height=length//resX
	gpu.copy(1,1,resX,resY-1,0,-height)
	gpu.fill(1,resY-height,resX,resY-1," ")
	cx,cy=term.getCursor()
    term.setCursor(1,resY)
	print(remotename..":"..remotemessage)
	term.setCursor(cx,cy)
end
local id=event.listen("modem_message",process_message)
term.scroll(resY)
term.setCursor(1,resY)
while 1 do
while 1 do
	io.write(">")
	xpcall(function() message=io.read() end,function() event.ignore("modem_message",process_message) os.exit() end)
	if message=="" then break end
	if not message then event.ignore("modem_message",process_message) os.exit() end
	tunnel.send(name,message)
	break
end
end
