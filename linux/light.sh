#!/bin/bash

# Set brightness level (0 to 100)
BRIGHTNESS=$1

# Apply brightness to both monitors
ddcutil setvcp 10 $BRIGHTNESS --display 1
ddcutil setvcp 10 $BRIGHTNESS --display 2
