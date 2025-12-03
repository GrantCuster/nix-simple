#!/bin/sh

STATE_FILE="/tmp/nvim_focus_state"
vim_focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

if [ "$vim_focused" != "false" ]; then
  nvr --servername /tmp/main.sock --remote-send "<C-\><C-n><C-i>" 
else
  current_window_id=$(niri msg -j focused-window | jq -r '.id')
  # Move current window to "store" workspace
  niri msg action move-window-to-workspace --focus false "store"
  niri msg action set-window-width --id "$current_window_id" proportion 0.5
  niri msg action set-window-height --id "$current_window_id" proportion 1
  niri msg action move-window-to-tiling --id "$current_window_id"

  if [ -n "$vim_window_id" ]; then
    sleep 0.1
    niri msg action focus-window --id "$vim_window_id"
    nvr --servername /tmp/main.sock --remote-send "<C-\><C-n><C-i>" 
  fi
fi
