#!/bin/bash
stdbuf -oL python test/sw/deadmanswitch.py >> /test/sw/log.txt
