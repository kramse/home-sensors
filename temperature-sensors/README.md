# Temperature sensors

Small project for measuring temperature in a large house.
Based on Wemos D1 Mini and One Wire digital temperature sensor DS18B20.

Data is sent through MQTT through a Python gateway into Grafana.

The circuit is hardly a circuit, only the temp sensor and a single resistor. Your electronic skills are probably better than mine, see the picture in the pics dir.

YMMV.

If you want to use this, do the following steps below


## Flash your device using the Firmware

```
$ sh install-firmwarenodemcu-release-19-modules-2020-10-20-19-03-21.sh
esptool.py v2.5.1
Serial port /dev/ttyUSB0
Connecting....
Detecting chip type... ESP8266
Chip is ESP8266EX
Features: WiFi
MAC: 48:3f:da:0c:76:e7
Enabling default SPI flash mode...
Configuring flash size...
Erasing flash...
Flash params set to 0x0240
Took 1.96s to erase flash block
Wrote 663552 bytes at 0x00000000 in 68.6 seconds (77.4 kbit/s)...

Leaving...
Hard resetting via RTS pin...
```

## Copy code
Copy the Lua files onto the device

The system I use is from Flemming Jacobsen, Batmule. He shared his files, which I updated and changed a bit. Errors are probably mine.

## Setid - optional step

Interrupt the boot process, and get the MAC for the device:
```
NodeMCU 3.0.0.0 built on nodemcu-build.com provided by frightanic.com
	branch: release
	commit: 64bbf006898109b936fcc09478cbae9d099885a8
	release: 3.0-master_20200910
	release DTS: 202009090323
	SSL: true
	build type: float
	LFS: 0x0 bytes total ctp,tmr,uart,wifi,ws2812,tls
 build 2020-10-20 19:02 powered by Lua 5.1.4 on SDK 3.0.1-dev(fce080e)

Henrik Kramselund hkj@kramse.org
Original by:
Flemming Jacobsen fj@batmule.dk

- Files on system:  - - - - - - - - - -
ls.lua              209 bytes
owread.lua         4350 bytes
init.lua           1234 bytes
- - - - - - - - - - - - - - - - - - - -
> panic=1
panic=1
> =wifi.sta.getmac()
=wifi.sta.getmac()
48:3f:da:0c:76:e7
```

Put this into setid.lua, re-upload and run that one.

```
dofile("setid.lua")
dofile("setid.lua")
MAC not found in list
wrote to file: 48:3f:da:0c:76:e7
>
```
This will allow you to see the device present itself using an ID, when sending MQTT messsages.


## Reboot and check settings
