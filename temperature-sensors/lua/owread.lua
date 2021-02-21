--
-- owread.lua - read all probes on ow. Assume they are all temp probes
--
-- Flemming Jacobsen fj160620
--
--
-- Defines:
--   Public:
--     owinit()
--     owscan()
--     owprint()
--     owreturn()
--     tohex()
--     probes
--     probeaddr_str	-- list of probeaddresses to be indexed with hex string addresses.
--   Private:
--     owennumerate()
--     owdelay
--     owtimert
--

-- Based on:
-- ds18b20 one wire example for NODEMCU (Integer firmware only)
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Vowstar <vowstar@nodemcu.com>

-- #COMPILE

-- dofile("owread.lua")

-- Add to capabilities
--system.capabilities = system.capabilities .. " OWREAD"

-- Do all initializing of ow bus, including scanning for probes.
function owinit(owtt)
  if(owtt == nil) then
    -- The delay between the timer fires
    owtimert = 60000
  else
    owtimert = owtt
  end

  -- The delay used when reading probes
  owdelay=10000

  ow.setup(pins.ow)
  owennumerate()

  -- Create list of probe addresses as strings
  probeaddr_str={}
  for k,v in pairs(probes) do
    probeaddr_str[tohex(k)] = k
  end

  --tmr.alarm(timers.ow, owtimert, tmr.ALARM_AUTO,owscan)
  owtimer = tmr.create()
  owtimer:register(owtimert, tmr.ALARM_AUTO, owscan)
  owtimer:start()
end


-- Scan the ow bus. Return list of addresses in probes.
function owennumerate()
  local addr = ow.reset_search(pins.ow)
  probes = {}
  repeat
    addr = ow.search(pins.ow)
    if(addr ~= nil) then
      -- print(addr:byte(1,8))
      crc = ow.crc8(string.sub(addr,1,7))
      if (crc ~= addr:byte(8)) then
	print("CRC is not valid!")
      else
	if ((addr:byte(1) ~= 0x10) and (addr:byte(1) ~= 0x28)) then
	  print("Device family is not recognized.")
	else
	  -- print("Device is a DS18S20 family device.")
	  probes [ addr ] = ""
	  -- addrh=tohex(addr)
	  -- print(addrh)
        end
      end
    end
  until(addr == nil)
end

-- Return addr as a hex string
function tohex(addr)
    local addrh=string.format("%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X",
		  addr:byte(1),addr:byte(2),addr:byte(3),addr:byte(4),
		  addr:byte(5),addr:byte(6),addr:byte(7),addr:byte(8))
    return addrh
end

-- Scan the bus and store readings in probes.
function owscan()
  local t
  local crc
  local i
  local data
  local t1
  local t2
  local sign
  local temp
  local present
  local addr
  local v

  print("Start owscan")
  for addr,v in pairs(probes) do
    -- Clear reading in case this one gets a bad CRC
    probes[addr] = ""

    ow.reset(pins.ow)
    ow.select(pins.ow, addr)
    ow.write(pins.ow, 0x44, 1)
    tmr.delay(owdelay)
    present = ow.reset(pins.ow)
    ow.select(pins.ow, addr)
    ow.write(pins.ow,0xBE,1)
    -- print("P="..present)
    data = nil
    data = string.char(ow.read(pins.ow))
    for i = 1, 8 do
      data = data .. string.char(ow.read(pins.ow))
    end
    -- print(data:byte(1,9))
    crc = ow.crc8(string.sub(data,1,8))
    -- print("CRC="..crc)
    if(data:byte(1)== 80 and data:byte(2) == 5) then
      -- Ignore the 85.0⁰C bogous reading (80 5) while sensor "boots".
      print("Ignoring 85.0⁰C reading")
      crc=""
    end

    if (crc == data:byte(9)) then
      t = (data:byte(1) + data:byte(2) * 256)

      -- handle negative temperatures
      if (t > 0x7fff) then
         t = t - 0x10000
      end

      if (addr:byte(1) == 0x28) then
         t = t * 625  -- DS18B20, 4 fractional bits
      else
         t = t * 5000 -- DS18S20, 1 fractional bit
      end

      local sign = ""
      if (t < 0) then
          sign = "-"
          t = -1 * t
      end

      -- Separate integral and decimal portions, for integer firmware only
      local t1 = string.format("%d", t / 10000)
      -- local t2 = string.format("%04u", t % 10000)
      -- local temp = sign .. t1 .. "." .. t2
      -- print(addrh.."  T= " .. temp)
      local t2 = string.format("%01u", (t % 10000 + 500)/1000 % 10)
      local temp = sign .. t1 .. "." .. t2
      --print(addrh .. "  T(°C)= " .. temp)
      probes[addr] = temp
    end
  end
  owprint()
  owmqtt()
end

function owprint()
  local addr
  local t
  for addr,t in pairs(probes) do
    print(tohex(addr) .. "  T(°C)= " .. t)
  end
end

function owreturn()
  local addr
  local t
  local s = ""
  for addr,t in pairs(probes) do
    s = s .. tohex(addr) .. "  T= " .. t .. "\n"
  end
  return s
end

function owmqtt()
  local addr
  local t
  if(mqstarted ~= nil and mqstarted ~= 0 ) then
    for addr,t in pairs(probes) do
      mqpublish(system.mqtt.temperatureprefix .. tohex(addr), t)
    end
  end
end
