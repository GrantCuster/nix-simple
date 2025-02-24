#!/bin/sh

# Calculate position
pos_x=$1
pos_y=$2
width=$3
height=$4

niri msg action move-window-to-floating
niri msg action set-window-width $width
niri msg action set-window-height $height

# Move floating window
niri msg action move-floating-window -x $pos_x -y $pos_y
