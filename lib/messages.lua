print(os.getenv)
if os.getenv then
	local language = os.getenv("LANGUAGE")
	print("language = " .. language)
	if language then
		local filename = "messages-" .. language .. ".lua"
		if require("filesystem").extsts("/lib/" .. filename) then
			return require(filename)
		end
	end
end

return require("messages-en")
