--
-- getid.lua - Return NodeMCU ID, based on the units MAC
--
--
-- Flemming Jacobsen fj170610
--

-- dofile("getid.lua")

-- Defines:
--   Public:
--     myid		-- read id from id.dat
--

myid=0			-- Should be set in init.lua

if(1==1) then
  local f
  f=file.open("id.dat","r")
  if(f) then
    myid=f.read(2)
    f.close()
  else
    myid=wifi.sta.getmac()
  end
end

--END--
