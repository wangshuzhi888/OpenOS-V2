local event = require("event")
local component = require("component")
local keyboard = require("keyboard")
local buffer = require("buffer")

local f, e = io.open("/var/log/dmesg", "rb")
if f then
	--buffer.write(io.stdout, buffer.read(f) .. "\n")
	repeat
		local line = buffer.read(f, "*L")
		if line then
			buffer.write(io.stdout, line)
		end
	until not line
	buffer.write(io.stdout, "\n")
else
	buffer.write(io.stderr, "/var/log/dmesg: " .. e .. "\n")
end

local interactive = io.output() == io.stdout
local color, isPal, evt
if interactive then
  color, isPal = component.gpu.getForeground()
end
io.write("Listening events...\nPress 'q' to exit\n")

local function print_event()
	repeat
		evt = table.pack(event.pull())
		if interactive then component.gpu.setForeground(0xCC2200) end
		io.write("[" .. os.date("%T") .. "] ")
		if interactive then component.gpu.setForeground(0x44CC00) end
		io.write(tostring(evt[1]) .. string.rep(" ", math.max(10 - #tostring(evt[1]), 0) + 1))
		if interactive then component.gpu.setForeground(0xB0B00F) end
		io.write(tostring(evt[2]) .. string.rep(" ", 37 - #tostring(evt[2])))
		if interactive then component.gpu.setForeground(0xFFFFFF) end
		if evt.n > 2 then
			for i = 3, evt.n do
				io.write("  " .. tostring(evt[i]))
			end
		end
		io.write("\n")
	until evt[1] == "key_down" and evt[4] == keyboard.keys.q
end
pcall(print_event)

if interactive then
	component.gpu.setForeground(color, isPal)
end
