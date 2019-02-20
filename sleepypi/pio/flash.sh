#!/bin/bash
cd /platformio
# flipping bit to stay alive
sudo i2cset -y 1 0x24 0xd c
# compiling and flashing of the sleepypi fw code
pio run -t upload --upload-port /dev/ttyAMA0 -v
# wait 3 sec for whatever
sleep 3
# flip bit for sleepypipi to be able to control the pi's power
sudo i2cset -y 1 0x24 0xf c
#pio device monitor -p /dev/ttyAMA0
