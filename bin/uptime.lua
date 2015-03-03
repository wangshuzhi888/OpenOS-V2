local computer = require("computer")
local buffer = require("buffer")

local args = { ... }
local seconds

if #args > 0 and args[1] == "-s" then
	local f, e = io.open("/proc/uptime", "r")
	if not f then
		buffer.write(io.stderr, "/proc/uptime: " .. e .. "\n")
		return
	end
	local up_s = buffer.read(f)
	if not up_s then
		buffer.write(io.stderr, "Read error\n")
		return
	end
	up_s = string.sub(up_s, 0, string.find(up_s, ".", 1, true) - 1)
	seconds = math.floor(tonumber(up_s))
else
	seconds = math.floor(computer.uptime())
end

local minutes, hours, days = 0, 0, 0
if seconds >= 60 then
	minutes = math.floor(seconds / 60)
	seconds = seconds % 60
end
if minutes >= 60 then
	hours = math.floor(minutes / 60)
	minutes = minutes % 60
end
if hours >= 24 then
	days = math.floor(hours / 24)
	hours = hours % 24
end
io.write(string.format("up time: %s%02d:%02d:%02d", days > 0 and days .. " days, " or "", hours, minutes, seconds))
