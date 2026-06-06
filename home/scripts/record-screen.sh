#!/bin/bash

RECORDINGS_DIR="$HOME/visuals/recordings"
TMP_FILE="/tmp/recording_screen.mp4"
PID_FILE="/tmp/recording_screen.pid"
STATUS_FILE="/tmp/rec_status"

mkdir -p "$RECORDINGS_DIR"

is_recording() {
  [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

set_status() {
  echo "$1" > "$STATUS_FILE"
}

clear_status() {
  echo "" > "$STATUS_FILE"
}

start() {
  set_status "REC"
  wf-recorder -f "$TMP_FILE" -c h264_vaapi -d /dev/dri/renderD128 &
  echo $! > "$PID_FILE"
  wait
}

stop() {
  if ! is_recording; then
    clear_status
    return
  fi

  kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
  if [ ! -f "$TMP_FILE" ]; then
    clear_status
    return
  fi

  set_status "PROCESSING"
  FILENAME="$RECORDINGS_DIR/$(date +"%Y-%m-%d_%H-%M-%S").mp4"
  ffmpeg -i "$TMP_FILE" \
    -c:v libx264 -crf 20 -preset slow \
    -pix_fmt yuv420p \
    -movflags +faststart \
    -vf "scale='trunc(iw/2)*2:trunc(ih/2)*2'" \
    -an \
    "$FILENAME" && rm "$TMP_FILE"
  clear_status
}

cancel() {
  if is_recording; then
    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    rm -f "$TMP_FILE"
    clear_status
  fi
}

case "${1:-toggle}" in
  cancel) cancel ;;
  *)      if is_recording; then stop; else start; fi ;;
esac
