if os.getenv then
	local language = os.getenv("LANGUAGE")
	print("language = " .. language)
	if language then
		local filename = "messages-" .. language
		if require("filesystem").exists("/lib/" .. filename .. ".lua") then
			return require(filename)
		end
	end
end

return require("messages-en")
