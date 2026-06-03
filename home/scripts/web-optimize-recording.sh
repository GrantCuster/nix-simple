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
  -vf "scale=-2:'trunc(min(1080,ih)/2)*2',fps=fps=60" \
  -an \
  "$output"

echo "" > "$STATUS_FILE"
