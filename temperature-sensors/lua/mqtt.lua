-- 
-- mqtt.lua - Setup MQTT
-- 
-- 
-- Flemming Jacobsen fj170525
--

-- #COMPILE

-- dofile("mqtt.lua")

-- Defines:
--   Public:
--     mqinit()
--     mqconnect()	-- Connect to server
--     mqstop()
--     mqsubscribe(sub)
--     mqpublish(topic,payload)
--     mqperiodic()	-- Reestablish connection, if down. Call periodically.
--     mqstarted	-- Should mq functions be called
--     mqdorestart      -- Controls if MQ may restart if connection is lost.
--                      -- If undeined, treat as 1
--   Private:
--     mqsubs		-- List of subscriptions (to restore if connection fails)
--     mqnoffline	-- Number of times MQ has gone offline, without recieving a mesage
--     mqreconnected()	-- Setup stuff after a reconnect


mqvalid=0;		-- Valid connection exists
mqstarted=0;		-- We want mq to be running

-- Add to capabilities
-- system.capabilities = system.capabilities .. " MQTT"

function mqconnect()
  -- If mq has not been configured in system, then bail
  if(system == nil or system.mqtt == nil) then
    print "*** No system.mqtt"
    return
  end

  -- If connection is not valid and we want mq to be started
  -- This allows a race where we can attempt a setup while a previous setup is in progress
  if(mqstarted ~= 0 and mqvalid == 0) then
    mq:lwt("/lwt", system.mqtt.id .. " offline", 1, 0)
    mq:on("connect", function(client)
      mqvalid=1;
      print ("MQTT connected")
      mqpublish(system.mqtt.statusprefix .. system.mqtt.id, "Connected")

      if(mqsubs ~= nil) then
	-- If we have setup subscriptions previously, just reestablish them.
	mqreconnected()
	print("MQTT subscriptions restored")
	mqpublish(system.mqtt.statusprefix .. system.mqtt.id, "Subscriptions restored")
      else
	-- If connecting first time, publish the boot reason
	-- local ra,rb = node.bootreason()
	local rawcode, reason, exccause, epc1, epc2, epc3, excvaddr, depc = node.bootreason()
	if(exccause == nil) then exccause = "nil" end
	if(epc1 == nil) then epc1 = "nil" end
	if(epc2 == nil) then epc2 = "nil" end
	if(epc3 == nil) then epc3 = "nil" end
	if(excvaddr == nil) then excvaddr = "nil" end
	if(depc == nil) then depc = "nil" end
	mqpublish(system.mqtt.statusprefix .. system.mqtt.id,
		  "Boot reason: " .. rawcode .. " " .. reason .. " " .. exccause .. " " .. epc1 .. " " .. epc2 .. " " .. epc3 .. " " .. excvaddr .. " " .. depc)

	if(mqsub ~= nil) then
	  mqsub()
	  print("MQTT subscriptions set")
	  mqpublish(system.mqtt.statusprefix .. system.mqtt.id, "Subscriptions set")
	end
      end

      end)
    mq:on("offline", function(client)
      print ("MQTT offline")
      mqvalid=0;
      mqnoffline=mqnoffline+1;

      -- If we have been offline too mny times, without getting a message, something might be amiss. Restart.
      if(mqnoffline==10) then
	if(mqdorestart == nil or mqdorestart == 1) then
	  node.restart()
	end
      end
      end)

    mq:on("message", function(client, topic, data)
      if(mqmessage ~= nil) then
        mqmessage(topic, data)
	mqnoffline=0			-- Message recieved, reset offline count
      else
	print(topic .. ":" )
	if data ~= nil then
	  print(data)
	end
      end
    end)

    mq:connect(system.mqtt.server, system.mqtt.port, false);
  end
end

function mqinit()
  if(system.mqtt == nil) then
    return
  end

  mqsubs=nil		-- Clear list of existing subscriptions
  mqnoffline=0		-- Reset offline count

  if(wifi.sta.getip() == nil) then
    print("*** No IP")
  else
    mqstarted=1
    mq=mqtt.Client(system.mqtt.id, system.mqtt.timeout);

    mqconnect()

    -- Create timer to handle periodic recconnect attempts
    mqretimer = tmr.create()
    mqretimer:register(60000, tmr.ALARM_AUTO, mqperiodic)
    mqretimer:start()
  end
end

function mqstop()
  mqstarted=0
  mqvalid=0;
  mq:close()
end

function mqpublish(topic,payload)
  if(mqvalid == 0) then
    mqconnect()
  else 
    mq:publish(topic,payload,1,0)
  end
end

function mqsubscribe(sub)
  if(system.mqtt == nil) then
    return
  end

  mq:subscribe(sub,1)
  if(mqsubs == nil) then
    mqsubs={}
  end
  mqsubs[sub] = 1
  if(system.mqtt.debug ~= nil and system.mqtt.debug ~= 0) then
    print("MQ subscribed to: " .. sub)
  end
end

function mqperiodic()
  if(mqvalid == 0) then
    mqconnect()
  end
end

-- Setup everything after a reconnect. Perhaps the server was restarted.
function mqreconnected()
  -- if(system.mqtt.debug ~= nil and system.mqtt.debug >= 2) then
  --   print("mqreconnected()")
  -- end
  if(mqsubs ~= nil) then
    for k,v in pairs(mqsubs) do
      mqsubscribe(k)
      if(system.mqtt.debug ~= nil and system.mqtt.debug >= 2) then
	print("mqreconnected() resubscribed to: " .. k)
      end
    end
  end
end
