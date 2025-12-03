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
  niri msg action close-window
  TARGET="${current_window_id}.app"
  nvr --servername /tmp/main.sock --remote-expr "execute('CloseApp $TARGET')"
  niri msg action focus-window --id "$vim_window_id"
fi
