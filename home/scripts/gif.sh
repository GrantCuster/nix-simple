#!/bin/bash

TMP_FILE_UNOPTIMIZED="/tmp/recording_unoptimized.gif"
TMP_PALETTE_FILE="/tmp/palette.png"
TMP_MP4_FILE="/tmp/recording.mp4"
APP_NAME="GIF recorder"

gif_dir="$HOME/Gifs"
filename=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="$gif_dir/$filename.gif"

if [ ! -d "$gif_dir" ]; then
  mkdir -p "$gif_dir"
fi

WINDOWS=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')

is_recorder_running() {
  pgrep -x wf-recorder >/dev/null
}

convert_to_gif() {
  ffmpeg -i "$TMP_MP4_FILE" -filter_complex "[0:v] palettegen" "$TMP_PALETTE_FILE"
  ffmpeg -i "$TMP_MP4_FILE" -i "$TMP_PALETTE_FILE" -filter_complex "[0:v] fps=10,scale=1040:-1,setpts=0.666*PTS [new];[new][1:v] paletteuse" "$TMP_FILE_UNOPTIMIZED"
  if [ -f "$TMP_PALETTE_FILE" ]; then
    rm "$TMP_PALETTE_FILE"
  fi
  if [ -f "$TMP_MP4_FILE" ]; then
    rm "$TMP_MP4_FILE"
  fi
}

notify() {
  notify-send -a "$APP_NAME" "$1" -t 2000
}

optimize_gif() {
  gifsicle -O3 --lossy=100 -i "$TMP_FILE_UNOPTIMIZED" -o "$FILENAME"
  if [ -f "$TMP_FILE_UNOPTIMIZED" ]; then
    rm "$TMP_FILE_UNOPTIMIZED"
  fi
}

screen() {
  timeout 30 wf-recorder -f "$TMP_MP4_FILE"
}

window() {
  GEOMETRY=$(echo "$WINDOWS" | slurp)
  if [[ ! -z "$GEOMETRY" ]]; then
    timeout 30 wf-recorder -g "$GEOMETRY" -f "$TMP_MP4_FILE"
  fi
}

area() {
  GEOMETRY=$(slurp)
  if [[ ! -z "$GEOMETRY" ]]; then
    timeout 30 wf-recorder -g "$GEOMETRY" -f "$TMP_MP4_FILE"
  fi
}

stop() {
  if is_recorder_running; then
    kill $(pgrep -x wf-recorder)

    notify "Post-processing started. GIF was stopped."
    convert_to_gif
    optimize_gif
    wl-copy -t image/png < $FILENAME
    notify "GIF capture completed. GIF saved to clipboard and $FILENAME"
    google-chrome-stable --new-window --ozone-platform=wayland $FILENAME
  fi
}

case "$1" in
  screen)
    screen
    ;;
  window)
    window
    ;;
  area)
    area
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {screen|window|area|stop}"
    exit 1
    ;;
esac
