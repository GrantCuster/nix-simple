#!/bin/sh

TMP_FILE_UNOPTIMIZED="/tmp/recording_unoptimized.gif"
TMP_PALETTE_FILE="/tmp/palette.png"
TMP_ACTIVE_FILE_REF="/tmp/active"
TMP_REC_STATUS_FILE="/tmp/rec_status"

APP_NAME="GIF recorder"

gif_dir="$HOME/gifrecordings"
filename=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="$gif_dir/$filename.gif"

mp4_dir="$HOME/screenrecordings"
MP4_FILE="$mp4_dir/$filename.mp4"

if [ ! -d "$gif_dir" ]; then
  mkdir -p "$gif_dir"
fi
if [ ! -d "$mp4_dir" ]; then
  mkdir -p "$mp4_dir"
fi

WINDOWS=$(sh ~/.config/niri/scripts/windows.sh)

is_recorder_running() {
  pgrep -x wf-recorder >/dev/null
}

convert_to_gif() {
  FILE="$(cat "$TMP_ACTIVE_FILE_REF")"
  ffmpeg -i "$FILE" -filter_complex "[0:v] palettegen" "$TMP_PALETTE_FILE"
  ffmpeg -i "$FILE" -i "$TMP_PALETTE_FILE" -filter_complex "[0:v] fps=10,scale=-1:720,setpts=1.0*PTS [new];[new][1:v] paletteuse" "$TMP_FILE_UNOPTIMIZED"
  if [ -f "$TMP_PALETTE_FILE" ]; then
    rm "$TMP_PALETTE_FILE"
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
  echo "$MP4_FILE" > "$TMP_ACTIVE_FILE_REF"
  echo "REC"  > "$TMP_REC_STATUS_FILE"
  timeout 30 wf-recorder -f "$MP4_FILE"
}

window() {
  echo "$MP4_FILE" > "$TMP_ACTIVE_FILE_REF"
  echo "REC"  > "$TMP_REC_STATUS_FILE"
  GEOMETRY=$(echo "$WINDOWS" | slurp)
  if [[ ! -z "$GEOMETRY" ]]; then
    timeout 30 wf-recorder -g "$GEOMETRY" -f "$MP4_FILE"
  fi
}

area() {
  echo "$MP4_FILE" > "$TMP_ACTIVE_FILE_REF"
  echo "REC"  > "$TMP_REC_STATUS_FILE"
  GEOMETRY=$(slurp)
  if [[ ! -z "$GEOMETRY" ]]; then
    timeout 30 wf-recorder -g "$GEOMETRY" -f "$MP4_FILE"
  fi
}

stop() {
  if is_recorder_running; then
    kill $(pgrep -x wf-recorder)

    echo "PROC"  > "$TMP_REC_STATUS_FILE"
    notify "Post-processing started. GIF was stopped."
    convert_to_gif
    optimize_gif
    echo ""  > "$TMP_REC_STATUS_FILE"
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
