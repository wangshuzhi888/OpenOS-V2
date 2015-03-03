local unicode = require("unicode")

local args = { ... }
local format = "%F %T"
if #args > 0 and unicode.sub(args[0], 1, 1) == "+" then
	format = unicode.sub(args[0], 1)
end
print(os.date(format))
