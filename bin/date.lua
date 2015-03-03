local unicode = require("unicode")

local args = { ... }
local format = "%F %T"
if #args > 0 and unicode.sub(args[1], 1, 1) == "+" then
	format = unicode.sub(args[1], 2)
end
print(os.date(format))
