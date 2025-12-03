#!/bin/sh

STATE_FILE="/tmp/nvim_focus_state"
vim_focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

if [ "$vim_focused" == "false" ]; then
  current_window_id=$(niri msg -j focused-window | jq -r '.id')
  TARGET="${current_window_id}.app"
  # Move current window to "store" workspace and focus vim

  # Batch niri actions using IPC helper
  SCRIPT_DIR="$(dirname "$0")"
  "$SCRIPT_DIR/niri_ipc.sh" \
    "{\"MoveWindowToWorkspace\":{\"window_id\":$current_window_id,\"reference\":{\"Name\":\"store\"},\"focus\":false}}" \
    "{\"FocusWindow\":{\"id\":$vim_window_id}}"

  nvr --servername /tmp/main.sock --remote-expr "execute('FocusApp $TARGET')"
fi

# Open window list
nvr --servername /tmp/main.sock --remote-expr "execute('WindowSwitcher')"
