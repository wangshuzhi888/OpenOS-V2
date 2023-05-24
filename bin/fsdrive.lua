c = require("component")
tty = require("tty")
while true do
  tty.clear()
  print("Unmananed Filesystem")
  print("1.写入\n2.读取\n3.删除\n4.格式化\n5.Exit")
  s=io.read()
  if s == "1" then
    io.write("选择扇区(1~"..(c.drive.getPlatterCount()*1024).."):\n")
    sq=tonumber(io.read())
    io.write("请输入文件内容:\n")
    ft=io.read()
    ftv=#ft
    if ftv > 512 then
      io.write("字符数量超出限制!\n")
    else
      c.drive.writeSector(sq,ft)
      io.write("\nDone!")
      io.write("\n字数:"..ftv)
    end
    io.write("\n按下回车继续...")
    io.read()
  end
  if s == "2" then
    io.write("选择扇区(1~"..(c.drive.getPlatterCount()*1024).."):\n")
    sqr=tonumber(io.read())
    print("文件内容:")
    rs=c.drive.readSector(sqr)
    print(rs)
    io.write("\n按下回车继续...")
    io.read()
  end
  if s == "3" then
    io.write("选择扇区(1~"..(c.drive.getPlatterCount()*1024).."):\n")
    sq2=tonumber(io.read())
    sq3=sq2*512
    sq4=sq3-511
    for i=sq4 ,sq3 do
      io.write("\r删除中...("..i.."/"..sq3..")")
      c.drive.writeByte(i,0x00)
    end
    io.write("\n按下回车继续...")
    io.read()
    end
  if s == "4" then
    for i=1, c.drive.getCapacity() do
      c.drive.writeByte(i,0x00)
      io.write("\r格式化中...".."("..i.."/"..c.drive.getCapacity()..")")
      io.write("\n按下回车继续...")
      io.read()
    end
  end
  if s == "5" then
    break
  end
end
