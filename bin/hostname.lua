local buffer = require("buffer")

local args = { ... }
if #args > 0 then
	local hostname = nil
	if args[1] == "-h" or args[1] == "--help" then
		print("Usage:\n" ..
			"	hostname [-f|-s]\n" ..
			"	hostname {-F|--file} <file>\n" ..
			"	hostname <hostname>\n")
		return
	end
	if args[1] == "-F" or args[1] == "--file" then
		if #args < 2 then
			buffer.write(io.stderr, "hostname: Option '" .. args[1] .. "' requires an argument\n")
			return
		end
		if #args > 2 then
			buffer.write(io.stderr, "hostname: Too many operand\n")
			return
		end
		local f, e = io.open(args[2], "rb")
		if not f then
			buffer.write(io.stderr, args[2] .. ": " .. e .. "\n")
			return
		end
		hostname = buffer.read(f)
		buffer.close(f)
	else
		if #args > 1 then
			buffer.write(io.stderr, "hostname: Too many operand\n")
			return
		end
		hostname = args[1]
	end
	local file, reason = io.open("/etc/hostname", "w")
	if not file then
		buffer.write(io.stderr, reason .. "\n")
		return
	end
	buffer.write(file, hostname)
	buffer.close(file)
	os.setenv("HOSTNAME", hostname)
--	os.setenv("PS1", "$HOSTNAME:$PWD# ")
else
	local file = io.open("/etc/hostname", "r")
	if file then
		io.write(buffer.read(file, "*l"), "\n")
		buffer.close(file)
	else
		buffer.write(io.stderr, "Hostname not set\n")
	end
end
