# KeePiLive
Code to keep a Raspberry Pi running forever when using balena.io and the SleepyPi

## Set-Up
 * Make a balena.io account
 * Buy a [SleepyPi2](https://spellfoundry.com/product/sleepy-pi-2/)
 * Follow the [guide](https://www.balena.io/docs/learn/getting-started/raspberrypi3/python/) to set-up your Pi
   * If you havent worked with balena, i recommend following the whole tutorial to better understand the whole process of developement
   * To use the code of this repo instead run the following code **instead** of the code in the tutorial, when reaching the chapter [Deploy Code](https://www.balena.io/docs/learn/getting-started/raspberrypi3/python/#deploy-code)
     * `git clone https://github.com/zagatta-sonah/KeePiLive.git`
     * `cd KeePiLive`
     * `git remote add balena <USERNAME>@git.balena-cloud.com:<USERNAME>/<APPNAME>.git`
   * When creating a application in balena, make sure for it to have the following settings:
     * Use a **production images**
     * Device Configuration:
       * Enable: RESIN_HOST_CONFIG_enable_uart
       * RESIN_HOST_CONFIG_dtoverlay = pi3-miniuart-bt
       * RESIN_HOST_CONFIG_dtparam = "i2c_arm=on","spi=on","audio=on"


## Flash SleepyPi2 Firmware

SSH into the "sleepypi" container (via balena cli or web interface) and run `/platformio/flash.sh` \n
The result should end with: \n
```
============================= [SUCCESS] Took 10.91 seconds =============================
```

## Explanations to different files in this Repo

### docker-compose.yml
Make sure NOT to put preformance limitations on the SleepyPi container \n

The Container needs to access the GPIO Pins (to pulse the reset line) and the UART bus (to flash the sleepypi fw). If all of these settings are actually necessary is not yet determined.

```
labels:
  io.resin.features.kernel-modules: '1'
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

### custom-avrdude.py
 * Changes the Environtment Variable "UPLOADER" to the the path of the *avrdude-pi.sh* script.

### avrdude-pi.sh
 * Pulses the Reset-Line to activate flashing process for the SleepyPi microcontroller
 * Calls the real *avrdude* with the original arguments

### flash.sh
Script for flashing the Firmware.
 * Flips the power-control bit on the SleepyPi -> SleepyPi can't cut power off anymore
 * Starts compiling and flashing process of the SleepyPi FW
 * Flips the power-control bit again ->
   * SleepyPi will can cut the power off again from Pi

### /src/main.cpp
Arduino code in c++ format (not Arduino code .ino)
-> The actual SleepyPi FW we're flashing
