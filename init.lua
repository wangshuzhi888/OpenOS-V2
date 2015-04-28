do
	_G._OSVERSION = "OpenOS 1.5"

	local component = component
	local computer = computer
	local unicode = unicode
--	local buffer = buffer

  -- Runlevel information.
  local runlevel, shutdown = "S", computer.shutdown
  computer.runlevel = function() return runlevel end
  computer.shutdown = function(reboot)
    runlevel = reboot and 6 or 0
    if os.sleep then
      computer.pushSignal("shutdown")
      os.sleep(0.1) -- Allow shutdown processing.
    end
    shutdown(reboot)
  end

  -- Low level dofile implementation to read filesystem libraries.
  local rom = {}
  function rom.invoke(method, ...)
    return component.invoke(computer.getBootAddress(), method, ...)
  end
  function rom.open(file) return rom.invoke("open", file) end
  function rom.read(handle) return rom.invoke("read", handle, math.huge) end
  function rom.close(handle) return rom.invoke("close", handle) end
  function rom.inits() return ipairs(rom.invoke("list", "boot")) end
  function rom.isDirectory(path) return rom.invoke("isDirectory", path) end

  local screen = component.list('screen')()
  for address in component.list('screen') do
    if #component.invoke(address, 'getKeyboards') > 0 then
      screen = address
    end
  end

	-- Report boot progress if possible.
	local gpu = component.list("gpu", true)()
	local w, h
	if gpu and screen then
		component.invoke(gpu, "bind", screen)
		w, h = component.invoke(gpu, "getResolution")
		component.invoke(gpu, "setResolution", w, h)
		component.invoke(gpu, "setBackground", 0x000000)
		component.invoke(gpu, "setForeground", 0xFFFFFF)
		component.invoke(gpu, "fill", 1, 1, w, h, " ")
	end
	local y = 1
	local logfile = nil
	local nolog = false
	local buffer = nil
	local function status(msg, log_to_file)
		msg = string.format("[%8.2f] ", computer.uptime()) .. msg
		if gpu and screen then
			component.invoke(gpu, "set", 1, y, msg)
			if y == h then
				component.invoke(gpu, "copy", 1, 2, w, h - 1, 0, -1)
				component.invoke(gpu, "fill", 1, h, w, 1, " ")
			else
				y = y + 1
			end
		end
		if nolog or not log_to_file or not io then
			return
		end
		if not buffer then
			buffer = require("buffer")
		end
		if not logfile then
			logfile = io.open("/var/log/dmesg", "wb")
			if not logfile then
				nolog = true
				return
			end
		end
		buffer.write(logfile, msg .. "\n")
		buffer.flush(logfile)
	end

	status("Booting " .. _OSVERSION .. "...")

  -- Custom low-level loadfile/dofile implementation reading from our ROM.
  local function loadfile(file, log_to_file)
    status("> " .. file, log_to_file)
    local handle, reason = rom.open(file)
    if not handle then
      error(reason)
    end
    local buffer = ""
    repeat
      local data, reason = rom.read(handle)
      if not data and reason then
        error(reason)
      end
      buffer = buffer .. (data or "")
    until not data
    rom.close(handle)
    return load(buffer, "=" .. file)
  end

  local function dofile(file)
    local program, reason = loadfile(file, true)
    if program then
      local result = table.pack(pcall(program))
      if result[1] then
        return table.unpack(result, 2, result.n)
      else
        error(result[2])
      end
    else
      error(reason)
    end
  end

  status("Initializing package management...")

  -- Load file system related libraries we need to load other stuff moree
  -- comfortably. This is basically wrapper stuff for the file streams
  -- provided by the filesystem components.
  local package = dofile("/lib/package.lua")

  do
    -- Unclutter global namespace now that we have the package module.
    _G.component = nil
    _G.computer = nil
    _G.process = nil
    _G.unicode = nil

    -- Initialize the package module with some of our own APIs.
    package.preload["buffer"] = loadfile("/lib/buffer.lua")
    package.preload["component"] = function() return component end
    package.preload["computer"] = function() return computer end
    package.preload["filesystem"] = loadfile("/lib/filesystem.lua")
    package.preload["io"] = loadfile("/lib/io.lua")
    package.preload["unicode"] = function() return unicode end

    -- Inject the package and io modules into the global namespace, as in Lua.
    _G.package = package
    _G.io = require("io")
  end

  status("Initializing file system...")

  -- Mount the ROM and temporary file systems to allow working on the file
  -- system module from this point on.
  local filesystem = require("filesystem")
  filesystem.mount(computer.getBootAddress(), "/")

  status("Running boot scripts...", true)

  -- Run library startup scripts. These mostly initialize event handlers.
  local scripts = {}
  for _, file in rom.inits() do
    local path = "boot/" .. file
    if not rom.isDirectory(path) then
      table.insert(scripts, path)
    end
  end
  table.sort(scripts)
  for i = 1, #scripts do
    dofile(scripts[i])
  end

  status("Initializing components...", true)

  local primaries = {}
  for c, t in component.list() do
    local s = component.slot(c)
    if not primaries[t] or (s >= 0 and s < primaries[t].slot) then
      primaries[t] = {address=c, slot=s}
    end
    computer.pushSignal("component_added", c, t)
  end
  for t, c in pairs(primaries) do
    component.setPrimary(t, c.address)
  end
  os.sleep(0.5) -- Allow signal processing by libraries.
  computer.pushSignal("init") -- so libs know components are initialized.

  status("Initializing system...", true)

	local f = io.open("/etc/environment")
	if f then
		local buffer = require("buffer")
		repeat
			local line = buffer.read(f, "*L")
			if not line then
				break
			end
			local start = string.find(line, "=")
			local stop = string.find(line, "\n")
			if not stop then
				stop = string.len(line) + 1
			end
			os.setenv(string.sub(line, 1, start - 1), string.sub(line, start + 1, stop - 1))
		until not line
		buffer.close(f)
	end

  require("term").clear()
  os.sleep(0.1) -- Allow init processing.
  runlevel = 1
end

local function motd()
  local f = io.open("/etc/motd")
  if not f then
    return
  end
  if f:read(2) == "#!" then
    f:close()
    os.execute("/etc/motd")
  else
    f:seek("set", 0)
    print(f:read("*a"))
    f:close()
  end
end

local buffer = require("buffer")

while true do
	local home = os.getenv("HOME")
	if home then
		os.setenv("PWD", home)
	end
	motd()
	local result, reason = os.execute(os.getenv("SHELL"))
	if not result then
		buffer.write(io.stderr, (tostring(reason) or "unknown error") .. "\n")
		print("Press any key to continue.")
		os.sleep(0.5)
		require("event").pull("key")
	end
	require("term").clear()
end
