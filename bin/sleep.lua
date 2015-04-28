local buffer = require("buffer")

local args = { ... }

if #args == 0 then
	print("Usage: sleep <seconds> [...]")
	return
end

for i = 1, #args do
	local s = tonumber(args[i])
	if not s then
		buffer.write(io.stderr, "sleep: Invalid number '" .. s .. "'\n")
		return
	end
	os.sleep(s)
end
