#!/bin/bash

# pulse reset line
sudo gpio -g mode 22 out
sudo gpio -g write 22 0
sleep 0.1
sudo gpio -g write 22 1

sudo /root/.platformio/packages/tool-avrdude/avrdude_bin $@
#-c arduino -b 57600 -p m328p -P /dev/ttyAMA0
