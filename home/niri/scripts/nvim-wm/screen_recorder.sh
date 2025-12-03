#!/usr/bin/env sh
mkdir -p ~/Videos
outfile=~/Videos/screenrecord_$(date +%Y-%m-%d_%H-%M-%S).mp4
# notify-send "🎥 Recording started" "$outfile"
wf-recorder -f "$outfile"
