local component = require("component")
local fs = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local text = require("text")
local buffer = require("buffer")

if not component.isAvailable("internet") then
	buffer.write(io.stderr, "This program requires an internet card to run.")
	return
end

args = { ... }
local non_options, options = shell.parse(...)
options.q = options.q or options.Q

if #non_options < 1 then
	io.write("Usage: wget [-fq] <url> [-O <filename>]\n")
	io.write(" -f: Force overwriting existing files.\n")
	io.write(" -q: Quiet mode - no status messages.\n")
	--io.write(" -Q: Superquiet mode - no error messages.")
	return
end

local filename = nil
local url = text.trim(non_options[1])
if options.O then
	local i = 1
	-- Don't scan the last arg
	while i < #args do
		if args[i] == "-O" then
			filename = args[i + 1]
			--print("filename: " .. filename)
			break
		end
		i = i + 1
	end
	if not filename then
		if not options.Q then
			buffer.write(io.stderr, "wget: Option '-O' requires an argument\n")
		end
		return nil, "Option '-O' requires an argument"
	end
else
	filename = url
	local index = string.find(filename, "/[^/]*$")
	if index then
		filename = string.sub(filename, index + 1)
	end
	index = string.find(filename, "?", 1, true)
	if index then
		filename = string.sub(filename, 1, index - 1)
	end
end
filename = text.trim(filename)
if filename == "" then
	if not options.Q then
		buffer.write(io.stderr, "could not infer filename, please specify one")
	end
	return nil, "missing target filename" -- for programs using wget as a function
end
filename = shell.resolve(filename)

if fs.exists(filename) then
	if not options.f or not os.remove(filename) then
		if not options.Q then
			buffer.write(io.stderr, "file already exists")
		end
		return nil, "file already exists" -- for programs using wget as a function
	end
end

local f, reason = io.open(filename, "wb")
if not f then
	if not options.Q then
		buffer.write(io.stderr, "failed opening file for writing: " .. reason)
	end
	return nil, "failed opening file for writing: " .. reason -- for programs using wget as a function
end

if not options.q then
	io.write("Downloading... ")
end
local result, response = pcall(internet.request, url)
if result then
	local result, reason = pcall(function()
		for chunk in response do
			buffer.write(f, chunk)
		end
	end)
	if not result then
		if not options.q then
			buffer.write(io.stderr, "failed.\n")
		end
		buffer.close(f)
		fs.remove(filename)
		if not options.Q then
			buffer.write(io.stderr, "HTTP request failed: " .. reason .. "\n")
		end
		return nil, reason		-- for programs using wget as a function
	end
	if not options.q then
		io.write("success.\n")
	end

	buffer.close(f)
	if not options.q then
		io.write("Saved data to " .. filename .. "\n")
	end
else
	if not options.q then
		io.write("failed.\n")
	end
	buffer.close(f)
	fs.remove(filename)
	if not options.Q then
		buffer.write(io.stderr, "HTTP request failed: " .. response .. "\n")
	end
	return nil, response -- for programs using wget as a function
end
return true -- for programs using wget as a function
