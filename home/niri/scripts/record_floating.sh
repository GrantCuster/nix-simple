#!/bin/sh

# Get logical width and height
width=$(niri msg -j focused-output | jq '.logical.width')
height=$(niri msg -j focused-output | jq '.logical.height')
output_x=$(niri msg -j focused-output | jq '.logical.x')
output_y=$(niri msg -j focused-output | jq '.logical.y')

mp4_dir="$HOME/screenrecordings"

# Define default sizes for each orientation
# Landscape
landscape_width=$((1920))
landscape_height=$((1080))

# Portrait
portrait_width=$((686))
portrait_height=$((1220))

# Square
square_size=$((1080))

# Function to calculate window position and size based on orientation
calculate_position_and_size() {
    local win_width=$1
    local win_height=$2
    local screen_width=$3
    local screen_height=$4

    # Calculate position (center of screen)
    local pos_x=$(((screen_width - win_width) / 2))
    local pos_y=$(((screen_height - win_height) / 2))

    # Adjust for any system bars (26px here as example)
    adjusted_y=$((pos_y - 26))

    echo "$pos_x $pos_y $win_width $win_height $adjusted_y $output_x $output_y"
}

# Function to start recording
start_recording() {
    orientation=$1

    case $orientation in
        landscape)
            win_width=$landscape_width
            win_height=$landscape_height
            ;;
        portrait)
            win_width=$portrait_width
            win_height=$portrait_height
            ;;
        square)
            win_width=$square_size
            win_height=$square_size
            ;;
        *)
            echo "Invalid orientation. Please choose 'landscape', 'portrait', or 'square'."
            exit 1
            ;;
    esac

    # Capture the position and size values into variables
    read pos_x pos_y win_width win_height adjusted_y output_x output_y <<< $(calculate_position_and_size $win_width $win_height $width $height)

    # Set window to floating mode and adjust size
    niri msg action move-window-to-floating
    niri msg action set-window-width $win_width
    niri msg action set-window-height $win_height

    # Move floating window
    niri msg action move-floating-window -x $pos_x -y $adjusted_y

    # Set the filename for the recording
    filename=$(date +"%Y-%m-%d_%H-%M-%S")
    MP4_FILE="$mp4_dir/$filename.mp4"

    leftx=$((output_x + pos_x))

    wf-recorder --geometry "${leftx},${pos_y} ${win_width}x${win_height}" -f "$MP4_FILE"
}

# Function to stop recording
stop_recording() {
    kill $(pgrep -x wf-recorder)
    notify-send "Screen recording stopped."

    niri msg action toggle-window-floating
    niri msg action set-window-width 50%
    niri msg action set-window-height 100%
    niri msg action move-floating-window -x 0 -y 0
    nautilus -w "$mp4_dir" &
}

# Main logic to handle 'start_recording' or 'stop_recording'
if [ "$1" = "stop_recording" ]; then
    stop_recording
else
    # Check the orientation argument passed to the script (default to landscape)
    orientation=${1:-landscape}
    start_recording $orientation
fi

