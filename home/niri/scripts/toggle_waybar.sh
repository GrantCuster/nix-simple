#!/bin/sh

CONFIG_PATH="$HOME/.config/waybar/config.jsonc"
CONFIG_PATH2="$HOME/.config/waybar/bottom.jsonc"

# Check if waybar with the specific config is running
if pgrep -f "waybar -c $CONFIG_PATH" > /dev/null; then
    # If running, kill it
    pkill -f "waybar -c $CONFIG_PATH"
    pkill -f "waybar -c $CONFIG_PATH2"
else
    # If not running, start it
    waybar -c $CONFIG_PATH & waybar -c $CONFIG_PATH2 &
fi

