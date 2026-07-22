#!/usr/bin/env bash
set -euo pipefail

WAYBAR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
WATCH_SCRIPT="$WAYBAR_CONFIG_DIR/scripts/niri-window-watch.sh"

for _ in {1..50}; do
  if niri msg --json workspaces >/dev/null 2>&1; then
    break
  fi

  sleep 0.1
done

waybar &
top_pid=$!

"$WATCH_SCRIPT" &
watch_pid=$!

wait "$top_pid" "$watch_pid" || true
