#!/bin/sh

if ! pgrep -x spotify_player > /dev/null; then
  ghostty -e spotify_player &
  sleep 5 
fi

niri msg action focus-monitor HDMI-A-1
niri msg action focus-workspace 255
google-chrome-stable --ozone-platform=wayland --password-store=basic --kiosk --app=http://wakeup.grantcuster.com/ &

echo "Starting playback of playlist"
spotify_player playback start context --id 37i9dQZF1DWUrPBdYfoJvz playlist

# start always turns off shuffle
sleep 5 

if [ "$(spotify_player get key playback | jq -r '.shuffle_state')" = "false" ]; then
  spotify_player playback shuffle
fi

# may need to dynamically get sink?
wpctl set-volume 69 0.8

echo "Skipping to next track"
spotify_player playback shuffle
spotify_player playback volume 80
spotify_player playback next
