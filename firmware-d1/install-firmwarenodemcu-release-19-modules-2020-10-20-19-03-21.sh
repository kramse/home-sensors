
IMAGE=nodemcu-release-19-modules-2020-10-20-19-03-21-float.bin
esptool --no-stub --port /dev/ttyUSB0 --baud 115200 write_flash -fm dio -fs 4MB 0x00000 $IMAGE
