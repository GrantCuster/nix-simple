#!/usr/bin/env bash
set -euo pipefail

WAYBAR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
WATCH_SCRIPT="$WAYBAR_CONFIG_DIR/scripts/niri-window-watch.sh"
BOTTOM_CONFIG="$WAYBAR_CONFIG_DIR/bottom.jsonc"

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

for _ in {1..60}; do
  if niri msg --json focused-window 2>/dev/null | jq -e '.workspace_id' >/dev/null 2>&1; then
    break
  fi

  sleep 0.25
done

waybar -c "$BOTTOM_CONFIG" &
bottom_pid=$!

wait "$top_pid" "$watch_pid" "$bottom_pid" || true
