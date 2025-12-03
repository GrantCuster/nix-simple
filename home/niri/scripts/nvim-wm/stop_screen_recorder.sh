#!/usr/bin/env sh
set -euo pipefail

# Stop the recorder
pkill -INT -x wf-recorder && notify-send "🛑 Recording stopped"

# Wait a moment for the file to be fully written
sleep 1

# Find the most recent windowrecord_* or screenrecord_* file
latest_video=$(ls -t ~/Videos/windowrecord_*.mp4 ~/Videos/screenrecord_*.mp4 2>/dev/null | head -n1)

if [ -z "$latest_video" ]; then
    notify-send "⚠️ No recording found to optimize"
    exit 0
fi

notify-send "🔄 Optimizing video..." "$(basename "$latest_video")"

# Create temporary output file
temp_output="${latest_video%.mp4}_optimized.mp4"

# Run ffmpeg optimization
if ffmpeg -i "$latest_video" \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2,format=yuv420p,fps=30" \
    -c:v libx264 -preset medium -crf 18 \
    -c:a aac -b:a 192k \
    "$temp_output" 2>/dev/null; then

    # Replace original with optimized version
    mv "$temp_output" "$latest_video"
    notify-send "✅ Video optimized" "$(basename "$latest_video")"
else
    # Clean up temp file if ffmpeg failed
    rm -f "$temp_output"
    notify-send "❌ Optimization failed" "$(basename "$latest_video")"
    exit 1
fi
