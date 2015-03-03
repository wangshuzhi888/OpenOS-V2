local buffer = require("buffer")

local args = { ... }

if #args > 0 then
	if args[1] == "-h" or args[1] == "--help" then
		print("libdll.so ToolBox dummy for OpenOS")
		return
	end
	buffer.write(io.stderr, args[1] .. ": No such tool\n")
	return
end
print("Toolbox!")
