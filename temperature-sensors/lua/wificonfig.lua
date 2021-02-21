
-- Basic Wi-Fi settings for Nodemcu
print("Starting Wi-Fi configuration")

--connect to Access Point (DO NOT save config to flash)
station_cfg={}
station_cfg.ssid=system.wifi.ssid
station_cfg.pwd=system.wifi.pwd
station_cfg.save=false
wifi.sta.config(station_cfg)

--compact version
wifi.setcountry({country="DK", start_ch=1, end_ch=13, policy=wifi.COUNTRY_AUTO})
wifi.sta.autoconnect(1)
