local buffer = require("buffer")
local shell = require("shell")

local args = shell.parse(...)
if #args == 0 then
	repeat
		local read = io.read("*L")
		if read then
			io.write(read)
		end
	until not read
else
	for i = 1, #args do
		local file, reason
		if args[i] == "-" then
			file = io.stdin
			if not file then
				buffer.write(io.stderr, messages.EBADF .. "\n")
				return
			end
		else
			file, reason = io.open(shell.resolve(args[i]), "rb")
			if not file then
				buffer.write(io.stderr, reason .. "\n")
				return
			end
		end
		repeat
			local line = buffer.read(file, "*L")
			if line then
				io.write(line)
			end
		until not line
		if args[i] ~= "-" then
			buffer.close(file)
		end
	end
end