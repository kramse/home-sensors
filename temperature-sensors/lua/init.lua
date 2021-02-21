-- DEFAULT.init.lua for NodeCMU1
--
-- Flemming Jacobsen fj170528
--

myid=0			-- Allocate at top of heap
dofile("getid.lua")
dofile("setup.lua")
print()
print("Henrik Kramselund hkj@kramse.org")
print("Original by:")
print("Flemming Jacobsen fj@batmule.dk")
print()
print("- Files on system:  - - - - - - - - - -")
dofile("ls.lua")
print("- - - - - - - - - - - - - - - - - - - -")

dofile("wificonfig.lua")

print("Will now wait for a little while, use: panic=1 to interrupt")
-- Delay start to allow for panic to be set
--   Also allows for time to get an IP from WiFi & DHCP
local starttimer = tmr.create()
starttimer:register(10000, tmr.ALARM_SINGLE, function(t)
  if(panic == nil) then
    print("Starting system")

    print("Did we get an IP?")
    print(wifi.sta.getip())
    -- Check if we have got an IP, else restart
    if(wifi.sta.getip() == nil) then
      print("*** No IP. restarting")
      node.restart()
    end

    -- initializing
    pins = {}
    pins.ow = 4

    dofile("mqtt.lua")
    dofile("owread.lua")

    mqinit()
    owinit()


  end
  t:unregister()
end)
starttimer:start()
