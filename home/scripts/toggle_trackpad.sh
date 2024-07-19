#!/bin/bash

status=$(cat /sys/devices/pci0000:00/0000:00:15.0/i2c_designware.0/i2c-0/i2c-04CA00B1:00/0018:04CA:00B1.0001/input/input6/inhibited);

if ((status == 0)); then
    sudo echo 1 > /sys/devices/pci0000:00/0000:00:15.0/i2c_designware.0/i2c-0/i2c-04CA00B1:00/0018:04CA:00B1.0001/input/input6/inhibited;
else
    sudo echo 0 > /sys/devices/pci0000:00/0000:00:15.0/i2c_designware.0/i2c-0/i2c-04CA00B1:00/0018:04CA:00B1.0001/input/input6/inhibited;
fi
