local shell = require("shell")
local buffer = require("buffer")

local args = shell.parse(...)
local new_wd = nil
if #args == 0 then
	--io.write("Usage: cd <dirname>")
	local home = os.getenv("HOME")
	if not home then
		buffer.write(io.stderr, "cd: HOME not set\n");
		return
	end
	new_wd = home;
else
	new_wd = args[1];
end

local result, reason = shell.setWorkingDirectory(new_wd)
if not result then
	buffer.write(io.stderr, reason)
end
