local fs = require("filesystem")
local shell = require("shell")
local buffer = require("buffer")
local messages = require("messages")

local args, options = shell.parse(...)
if #args < 2 then
	io.write("Usage: mv [-f] <from> [...] <to>\n")
	io.write("	-f: Overwrite file if it already exists.")
	return
end

local to = shell.resolve(args[#args])
local todir = fs.isDirectory(to)

if not todir and #args > 2 then
	buffer.write(io.stderr, "mv: " .. messages.ENOTDIR)
	return
end

local i = 1
while i < #args do
	local from = shell.resolve(args[i])
	if todir then
		to = to .. "/" .. fs.name(from)
	end
	if fs.exists(to) then
		if not options.f then
			buffer.write(io.stderr, "target file exists")
			return
		end
		fs.remove(to)
	end

	local result, reason = os.rename(from, to)
	if not result then
		buffer.write(io.stderr, reason or "unknown error")
		if not options.f then
			return
		end
	end
	i = i + 1
end
