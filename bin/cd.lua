local shell = require("shell")
local buffer = require("buffer")

local args = shell.parse(...)
local new_wd = args[1]
if not new_wd then
	new_wd = "~"
end

local result, reason = shell.setWorkingDirectory(new_wd)
if not result then
	buffer.write(io.stderr, new_wd .. ": " .. reason)
end
