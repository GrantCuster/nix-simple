#!/bin/sh

STATE_FILE="/tmp/nvim_focus_state"
vim_focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

if [ "$vim_focused" == "false" ]; then
  current_window_id=$(niri msg -j focused-window | jq -r '.id')
  TARGET="${current_window_id}.app"
  # Move current window to "store" workspace
  niri msg action move-window-to-workspace --focus false "store"
  niri msg action focus-window --id "$vim_window_id"
  nvr --servername /tmp/main.sock --remote-expr "execute('FocusApp $TARGET')"
fi

# Open window list
nvr --servername /tmp/main.sock --remote-expr "execute('WindowSwitcher')"
