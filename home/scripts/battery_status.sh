#!/bin/bash

# Get the battery details
battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_CMB0)

# Extract battery percentage
percentage=$(echo "$battery_info" | grep -E "percentage:" | awk '{print $2}')

# Extract time to empty
time_to_empty=$(echo "$battery_info" | grep -E "time to empty" | awk '{print $4, $5, $6}')

# Extract battery state
state=$(echo "$battery_info" | grep -E "state:" | awk '{print $2}')

# Display formatted output
echo "$percentage ($state) - $time_to_empty"
