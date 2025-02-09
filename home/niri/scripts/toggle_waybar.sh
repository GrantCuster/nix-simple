#!/bin/sh

CONFIG_PATH="$HOME/.config/waybar/side.jsonc"

# Check if waybar with the specific config is running
if pgrep -f "waybar -c $CONFIG_PATH" > /dev/null; then
    # If running, kill it
    pkill -f "waybar -c $CONFIG_PATH"
else
    # If not running, start it
    waybar -c $CONFIG_PATH &
fi

