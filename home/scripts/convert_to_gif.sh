#!/bin/bash

TMP_FILE_UNOPTIMIZED="/tmp/recording_unoptimized.gif"
TMP_PALETTE_FILE="/tmp/palette.png"
MP4_FILE="$1"
APP_NAME="GIF recorder"

gif_dir="$HOME/visuals/gifs"
filename=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="$gif_dir/$filename.gif"

if [ ! -d "$gif_dir" ]; then
  mkdir -p "$gif_dir"
fi

convert_to_gif() {
  ffmpeg -i "$MP4_FILE" -filter_complex "[0:v] palettegen" "$TMP_PALETTE_FILE"
  ffmpeg -i "$MP4_FILE" -i "$TMP_PALETTE_FILE" -filter_complex "[0:v] fps=15,scale='if(gt(iw,1200),1200,iw)':-1 [new];[new][1:v] paletteuse" "$TMP_FILE_UNOPTIMIZED"
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

notify "GIF conversion started."
convert_to_gif
optimize_gif
notify "GIF capture completed."
google-chrome-stable --new-window --ozone-platform=wayland $FILENAME

