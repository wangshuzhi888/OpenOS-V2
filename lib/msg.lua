local msg = { }

function msg.get_messages()
	if not os.getenv then
		return require("messages-en")
	end
	local language = os.getenv("LANGUAGE")
--	print("language = " .. language)
	if not language then
		return require("messages-en")
	end
	local name = "messages-" .. language
	if require("filesystem").exists("/lib/" .. name .. ".lua") then
		return require(name)
	end
end

return msg

