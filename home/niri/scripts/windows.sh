#!/bin/sh

# Get logical width and height
width=$(niri msg -j focused-output | jq '.logical.width')
base_height=$(niri msg -j focused-output | jq '.logical.height')

bar_height=27
height=$(($base_height - $bar_height))

if [ "$width" -gt 2000 ]; then
    width_divider=3
else
    width_divider=2
fi

# Calculate window size (50% of screen)
half_width=$((width / 2))
half_height=$((height / 2))

echo "0,$((bar_height + 1)) ${half_width}x${height}
0,$((bar_height + 1)) ${half_width}x${half_height}
${half_width},$((bar_height + 1)) ${half_width}x${height}
${half_width},$((bar_height +  1)) ${half_width}x${half_height}
$((half_width * 2)),$((bar_height + 1)) ${half_width}x${half_height}
$((half_width * 2)),$((bar_height + 1)) ${half_width}x${height}"
