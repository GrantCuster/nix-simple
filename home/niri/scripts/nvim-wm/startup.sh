#!/bin/sh

sleep 1

ulimit -n 65535 && ghostty -e nvim --listen /tmp/main.sock -c "edit ~/base/base.vibe"

sleep 1

niri msg action focus-workspace "home"

# webcam fix
v4l2-ctl -d /dev/video3 --set-fmt-video=width=3840,height=2160,pixelformat=H264

# kickstart focus tracker bc it isn't working on startup
STATE_FILE="/tmp/nvim_focus_state"
window_id=$(echo "$focused_window" | jq -r '.id // ""')
printf "true\n%s\n" "$window_id" > "$STATE_FILE"
