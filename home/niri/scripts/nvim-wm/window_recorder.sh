#!/usr/bin/env sh
set -euo pipefail

win_json=$(niri msg --json focused-window)

# Extract floats safely via jq and trim whitespace
x=$(jq -r '.layout.tile_pos_in_workspace_view[0]' <<<"$win_json" | xargs printf "%.0f")
y=$(jq -r '.layout.tile_pos_in_workspace_view[1]' <<<"$win_json" | xargs printf "%.0f")
w=$(jq -r '.layout.window_size[0]' <<<"$win_json" | xargs printf "%.0f")
h=$(jq -r '.layout.window_size[1]' <<<"$win_json" | xargs printf "%.0f")

outfile=~/Videos/windowrecord_$(date +%Y-%m-%d_%H-%M-%S).mp4
mkdir -p ~/Videos

# notify-send "🎥 Window recording started" "(${w}x${h} at ${x},${y})"
wf-recorder -g "${x},${y} ${w}x${h}" -f "$outfile"

