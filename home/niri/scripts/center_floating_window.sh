#!/bin/sh

# Get logical width and height
width=$(niri msg -j focused-output | jq '.logical.width')
height=$(niri msg -j focused-output | jq '.logical.height')

# Calculate window size (50% of screen)
win_width=$((width / 2))
win_height=$((height / 2))

# Calculate position
pos_x=$(((width - win_width) / 2))
pos_y=$((((height - win_height) / 3) * 1))

niri msg action move-window-to-floating
niri msg action set-window-width 50%
niri msg action set-window-height 66%

# Move floating window
niri msg action move-floating-window -x $pos_x -y $pos_y
