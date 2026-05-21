#!/bin/bash

RECORDINGS_DIR="$HOME/visuals/recordings"

latest=$(ls -t "$RECORDINGS_DIR"/*.mp4 2>/dev/null | head -1)

if [ -z "$latest" ]; then
  exit 1
fi

google-chrome-stable --new-window --ozone-platform=wayland "$latest"
