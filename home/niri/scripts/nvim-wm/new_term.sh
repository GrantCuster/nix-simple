#!/bin/sh

STATE_FILE="/tmp/nvim_focus_state"
focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

if [ "$focused" != "false" ]; then
  nvr --servername /tmp/main.sock --remote-expr "execute('edit ~/base/today.vibe')"
else
  current_window_id=$(niri msg -j focused-window | jq -r '.id')

  # Move current window to "store" workspace
  niri msg action move-window-to-workspace --focus false "store"
  niri msg action set-window-width --id "$current_window_id" proportion 0.5
  niri msg action set-window-height --id "$current_window_id" proportion 1
  niri msg action move-window-to-tiling --id "$current_window_id"

  # Find the most recent nvim app tmp file and focus that window
  TARGET="${current_window_id}.app"

  nvr --servername /tmp/main.sock --remote-expr "execute('FocusApp $TARGET')"
  nvr --servername /tmp/main.sock --remote-expr "execute('edit ~/base/today.vibe')"
  niri msg action focus-window --id "$vim_window_id"
fi

