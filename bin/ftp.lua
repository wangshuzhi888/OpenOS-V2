args={...}
if #args~=1 then print("ftp <IP>") return end
ip=args[1]
c=require("component")
fs=require("filesystem")
function split(str, seperators)
  local t = {}
  for subst in string.gmatch(str, "[^"..seperators.."]+") do
    table.insert(t, subst)
  end
  if #t==0 then return {str} end
  return t
end
function openNet2(ip,port)
	net2=component.internet.connect(ip,port)
	net2.read()
	return net2
end
function readfile(path)
	d=""
	for i in io.lines(path) do
		d=d..i.."\n"
	end
	return d
end
function getPort(pasv)
	pasv1=split(pasv,",")
	num1=pasv1[5]
	pasv2=split(pasv1[6],")")
	num2=pasv2[1]
	port=num1*256+num2
	return port
end
net=c.internet.connect(ip,21)
net.read()
os.sleep(1)
io.write(net.read())
io.write("User: ")
user=io.read()
net.write(string.format("user %s\n",user))
io.write(net.read())
io.write("Password: ")
pass=io.read()
net.write(string.format("pass %s\n",pass))
uapit=net.read()
uapit1=split(uapit," ")
if uapit1[1]=="530" then io.write(uapit) return end
print(uapit)
print("Use 'exit' to exit.")
helpDOC=[[
exit ls help rm cd upload get cat raw mkdir rmdir
]]
while true do
	io.write(">")
	cmd=io.read()
	cmd2=split(cmd," ")
	if cmd=="exit" then break end
	if cmd=="ls" then 
		net.write("pasv\n")
		pasv=net.read()
		net.write("list\n")
		net2=openNet2(ip,getPort(pasv))
		net.read()
		io.write(net2.read())
	end
	if cmd=="help" then io.write(helpDOC) end
	if cmd2[1]=="rm" then
		net.write(string.gsub(string.format("dele %s\n",cmd2[2]),";"," "))
		io.write(net.read())
	end
	if cmd2[1]=="cd" then
		net.write(string.gsub(string.format("cwd %s\n",cmd2[2]),";"," "))
		io.write(net.read())
	end
	if cmd2[1]=="upload" then
		net.write("pasv\n")
		pasv=net.read()
		io.write(pasv)
		net2=openNet2(ip,getPort(pasv))
		net.write(string.gsub(string.format("stor %s\n",cmd2[2]),";"," "))
		io.write(net.read())
		net2.write(readfile(cmd2[2]))
		net.write("abor\n")
		io.write(net.read())
	end
	if cmd2[1]=="get" then
		net.write("pasv\n")
		pasv=net.read()
		io.write(pasv)
		net2=openNet2(ip,getPort(pasv))
		net.write(string.gsub(string.format("retr %s\n",cmd2[2]),";"," "))
		io.write(net.read())
		d=net2.read()
		file=fs.open("/tmp/"..cmd2[2],"w")
		print("File saved as: /tmp/"..cmd2[2])
		file:write(d)
		file:close()
	end
	if cmd2[1]=="cat" then
		net.write("pasv\n")
		pasv=net.read()
		net2=openNet2(ip,getPort(pasv))
		net.write(string.gsub(string.format("retr %s\n",cmd2[2]),";"," "))
		net.read()
		d=net2.read()
		print(d)
	end
	if cmd2[1]=="raw" then
		if not cmd2[2] then
			require("computer").pullSignal()
		else
			net.write(string.gsub(cmd2[2].."\n",";"," "))
			io.write(net.read())
		end
	end
	if cmd2[1]=="mkdir" then
		net.write(string.gsub(string.format("mkd %s\n",cmd2[2]),";"," "))
		io.write(net.read())
	end
	if cmd2[1]=="rmdir" then
		net.write(string.gsub(string.format("rmd %s\n",cmd2[2]),";"," "))
		io.write(net.read())
	end
end
