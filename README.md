# KeePiLive
Code to keep a Raspberry Pi running forever when using Balena.io and the SleepyPi


# Flash SleepyPi2 Firmware

This readme will explain the main steps in flashing the FW.
The Compiling and Flashing is done by the PlatformIO CLI core.

## Setting up the Container

### Balena Settings+
 * Only works with production images
 * Activate UART
 * RESIN_HOST_CONFIG_dtoverlay = pi3-miniuart-bt


### docker-compose.yml
It is not possible to run the flashing with these performance limitations, so they were removed

```
cpu_quota: '10000'
cpuset: '0'
mem_limit: '64m'
```

The Container needs to access the GPIO Pins (to pulse the reset line) and the UART bus (to flash the sleepypi fw). If all of these settings are actually necessary is not yet determined.

```
labels:
  io.balena.features.kernel-modules: '1'
devices:
  - "/dev/i2c-1:/dev/i2c-1"
cap_add:
  - SYS_RAWIO
```

### Dockerfile.template
PlatformIO needs Python 2.7 to run, thats why we need python2.7, pip2 and then can install the PlatformIO CLI core via pip.
Dockerfile basically consists of:

 * Python 2.7
 * Install pip for Python 2.7
 * Install PlatformIO CLI Core
 * Install framework for sleepypi microcontroller
 * Copy pio roject
 * install Wiring Pi for Pulsing GPIOs
 * activate i2c
 * RPi.GPIO

### /test/sw/start.sh
This Script is
 * switching the Handshake On/Off every 30 sec. \n
 * Logging the
    * time difference since last switch
    * the serial logs from the SleepyPi\n
to the same logfile "log.txt". We only need the switching of the deadmanswitch for the FW Integration.

## PlatformIO Project

### platformio.ini
PlatformIO Project definiton file. \n
Contains:
 * Dependencies for the SleepyPi FW (Git links)
 * Board Specification -> points to custom specification */boards/sleepypi_custom.json*
 * Specification of extra script to run before compiling and flashing
   * *custom-avrdude.py* to the avrdude to the *avrdude-pi.sh* script

### /boards/sleepypi_custom.json
Custom microcontroller board specification for the SleepyPi2.
 * Defines some important electrotechnical stuff.
 * Written by Daniel Krebs (enlyze)

### custom-avrdude.py
 * Changes the Environtment Variable "UPLOADER" to the the path of the *avrdude-pi.sh* script.
   * In case it's run on ARCH Linux, it will use the path appropriate.

*TODO:* We should just specify the path manually because its always going to be the same location

### avrdude-pi.sh
 * Pulses the Reset-Line to activate flashing process for the SleepyPi microcontroller
 * Calls the real *avrdude* with the original arguments

### flash.sh
Script for flashing the Firmware.
 * Flips the power-control bit on the SleepyPi -> SleepyPi can't cut power off anymore
 * Starts compiling and flashing process of the SleepyPi FW
 * Flips the power-control bit again ->
   * SleepyPi will can cut the power off again from Pi
   * Power will be cut of due to flipping the bit

### /src/main.cpp
Arduino code in c++ format (not Arduino code .ino)
-> The actual SleepyPi FW we're flashing
