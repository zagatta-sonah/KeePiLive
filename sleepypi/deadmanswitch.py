import time
import RPi.GPIO as GPIO
now = time.time()
delay = 30
handshake_mode = True
handshake_pin = 25

GPIO.setmode(GPIO.BCM)
GPIO.setup(25, GPIO.OUT)


def switchHandshake(mode):
    if(mode):
        output = GPIO.LOW
        handshake_mode = False
    else:
        output = GPIO.HIGH
        handshake_mode = True
    print(str(handshake_pin) + ":" + str(handshake_mode))
    GPIO.output(handshake_pin, output)
    return handshake_mode


while(True):
    if((time.time() - now) > (delay)):
        handshake_mode = switchHandshake(handshake_mode)
        now = time.time()
        print("last switch: " + str(now))
    time.sleep(1)
