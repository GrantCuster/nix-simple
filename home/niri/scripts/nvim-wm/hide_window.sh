#!/bin/sh

STATE_FILE="/tmp/nvim_focus_state"
vim_focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

if [ "$vim_focused" != "false" ]; then
  # Check if there is more than one window in vim
  window_count=$(nvr --servername /tmp/main.sock --remote-expr "winnr('$')")

  if [ "$window_count" -gt 1 ]; then
    nvr --servername /tmp/main.sock --remote-expr "execute('q')"
  fi
else
  current_window_id=$(niri msg -j focused-window | jq -r '.id')
  # Move current window to "store" workspace

  # Batch all niri actions using IPC helper
  SCRIPT_DIR="$(dirname "$0")"
  "$SCRIPT_DIR/niri_ipc.sh" \
    "{\"MoveWindowToWorkspace\":{\"window_id\":$current_window_id,\"reference\":{\"Name\":\"store\"},\"focus\":false}}" \
    "{\"SetWindowWidth\":{\"id\":$current_window_id,\"change\":{\"SetProportion\":0.5}}}" \
    "{\"SetWindowHeight\":{\"id\":$current_window_id,\"change\":{\"SetProportion\":1.0}}}" \
    "{\"MoveWindowToTiling\":{\"id\":$current_window_id}}"

  # Find the most recent nvim app tmp file and focus that window
  TARGET="${current_window_id}.app"

  nvr --servername /tmp/main.sock --remote-expr "execute('CloseApp $TARGET')"

  if [ -n "$vim_window_id" ]; then
    niri msg action focus-window --id "$vim_window_id"
  fi
fi
