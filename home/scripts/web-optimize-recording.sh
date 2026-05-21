#!/bin/bash

RECORDINGS_DIR="$HOME/visuals/recordings"
STATUS_FILE="/tmp/rec_status"

latest=$(ls -t "$RECORDINGS_DIR"/*.mp4 2>/dev/null | grep -v '\-web\.mp4$' | head -1)

if [ -z "$latest" ]; then
  exit 1
fi

base="${latest%.mp4}"
output="${base}-web.mp4"

echo "CONVERTING" > "$STATUS_FILE"

ffmpeg -i "$latest" \
  -c:v libx264 -crf 28 -preset slow \
  -pix_fmt yuv420p \
  -movflags +faststart \
  -vf "scale='min(1280,iw)':'trunc(oh*a/2)*2',scale='trunc(iw/2)*2:trunc(ih/2)*2'" \
  -an \
  "$output"

echo "" > "$STATUS_FILE"
