local shell = require("shell")
local buffer = require("buffer")

local args = shell.parse(...)
local new_wd
if args[1] then
	new_wd = shell.resolve(args[1])
else
	new_wd = "~"
end

local result, reason = shell.setWorkingDirectory(new_wd)
if not result then
	buffer.write(io.stderr, new_wd .. ": " .. reason)
end
