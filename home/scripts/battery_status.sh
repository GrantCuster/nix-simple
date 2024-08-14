#!/bin/bash

# Get the battery details
battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_CMB0)

# Extract battery percentage
percentage=$(echo "$battery_info" | grep -E "percentage:" | awk '{print $2}')

# Extract battery state
state=$(echo "$battery_info" | grep -E "state:" | awk '{print $2}')

# Display formatted output
echo "$percentage ($state)"
