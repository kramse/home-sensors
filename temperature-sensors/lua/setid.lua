--
-- setid.lua - Set ID# in id.dat
--
-- Flemming Jacobsen fj180124
--

-- dofile("setid.lua")

-- Defines:
--	N/A

-- Get value using:
--   =wifi.sta.getmac()

macs = {
	"48:3f:da:0c:96:e2";	--  1 sovevaerelset
				--	Breadboard temp sensor
	"48:3f:da:0c:73:3b";	--  2 udsigtsstuen
				--	Breadboard temp sensor
	"48:3f:da:0c:78:35";	--  3 badevaerelset
				--	Breadboard temp sensor
	"48:3f:da:0c:98:7f";	--  4
				--	Breadboard temp sensor
	"48:3f:da:0c:73:70";	--  5
				--	Box version1 Berits office
	"48:3f:da:0c:96:f6";	--  6
				--	Box version1 Bedroom
	"48:3f:da:0c:77:cd";		--  7
				--	minimal temp sensor, soldered directly onto D1
	"48:3f:da:0c:74:1b";		--  8
				--	prod temp sensor, soldered with wires onto D1
	"";	-- 36	- Need Windows for flashing  - D1 mini (clone)
				--	Storage
	}


function getid()
  local mac=wifi.sta.getmac()
  if(prefix == nil) then
    prefix = ""
  end
  if(macs ~= nil) then
    local i,m
    for i,m in pairs(macs) do
      if(m == mac) then
	return i
      end
    end
  else
    print "*** getid() no mac table"
  end
  if(prefix ~= "") then
    prefix = prefix .. "-"
  end
  print "MAC not found in list"
  return mac
end

id=getid()
fname="id.dat"
f=file.open(fname,"w")
if f then
  f.write(id)
  f.close()
  print("wrote to file: " .. id)
else
  print("Could not open " .. fname)
end

--END--
