local args = { ... }

if #args == 0 then
	for k,v in pairs(os.getenv()) do
		io.write(k .. "='" .. string.gsub(v, "'", [['"'"']]) .. "'\n")
	end
else
	local s = os.getenv(args[1])
	if s then
		print(s)
	end
end
