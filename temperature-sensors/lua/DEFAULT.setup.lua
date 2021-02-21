
-- setup.lua

-- Henrik Kramselund Jereminsen hkj@kramse.org


-- confidential

if(myid ~= nil) then
  system = {              -- HKJ system setup
  	  wifi	= 1;					-- Connect to WiFi?
      id    = "NodeMCU" .. myid;			-- ID of this board
      mqtt =        {
                  server  = "10.0.42.x";     -- MQTT server IP/name
                  port    = 1883;                       -- MQTT server port
                  timeout = 120;                        -- Connection timeout
                  -- id      = 0;                       -- ID of this client (set below)
                  debug   = 1;

                  temperatureprefix     = "/sensors/temperature/";
                  statusq		= "query";
                  owname		= "ow";
                  statusprefix		= "/status/";
                  };
      wifi = {
              ssid="something";
              pwd="withpassword";
            };
  }
  system.mqtt.id=system.id;	-- Referring to system.id does not work while setting system.mqtt.*
  myid=nil                      -- Free memory used by getid()

  if(sntp.sync == nil) then     -- If SNTP is not in image, don't use it
    system.ntp = 0
  end
else
  print("*** myid not set. Array 'system' not set")
end

--END--
