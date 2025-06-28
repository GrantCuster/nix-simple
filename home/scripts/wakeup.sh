#!/bin/sh

if ! pgrep -x spotify_player > /dev/null; then
  ghostty -e spotify_player &
  sleep 5 
fi

niri msg action focus-monitor HDMI-A-1
niri msg action focus-workspace 255
google-chrome-stable --ozone-platform=wayland --user-data-dir=/tmp --password-store=basic --kiosk --app=http://wakeup.grantcuster.com/ &

echo "Starting playback of playlist"
spotify_player playback start context --id 37i9dQZF1DWUrPBdYfoJvz playlist

# start always turns off shuffle
sleep 3 

if [ "$(spotify_player get key playback | jq -r '.shuffle_state')" = "false" ]; then
  spotify_player playback shuffle
fi

# need to dynamically get sink
dock_sink=$(wpctl status | awk -F '[.[]' '/USB Audio Headphones/ {gsub(/[^0-9]/, "", $1); print $1}')
stereo_sync=$(wpctl status | awk -F '[.[]' '/Built-in Audio Analog Stereo/ {gsub(/[^0-9]/, "", $1); print $1}')
wpctl set-volume "$dock_sink" 80%
wpctl set-volume "$stereo_sync" 100%

echo "Skipping to next track"
spotify_player playback volume 80
spotify_player playback next
