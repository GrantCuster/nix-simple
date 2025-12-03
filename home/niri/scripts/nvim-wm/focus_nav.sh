#!/bin/sh

# Usage: nvim_focus.sh <direction>
# direction: left, right, up, down
direction="$1"

case "$direction" in
  left)
    vim_cmd="h"
    app_cmd="LeftOfApp"
    ;;
  right)
    vim_cmd="l"
    app_cmd="RightOfApp"
    ;;
  up)
    vim_cmd="k"
    app_cmd="AboveApp"
    ;;
  down)
    vim_cmd="j"
    app_cmd="BelowApp"
    ;;
  *)
    echo "Usage: $0 {left|right|up|down}"
    exit 1
    ;;
esac

echo "uh"

STATE_FILE="/tmp/nvim_focus_state"
vim_focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")

if [ "$vim_focused" == "true" ]; then
  nvr --servername /tmp/main.sock --remote-expr "execute('wincmd $vim_cmd')"
else
  # not in vim
  current_window_id=$(niri msg -j focused-window | jq -r '.id')
  WINDOW_ID=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")
  TARGET="${current_window_id}.app"
  niri msg action focus-window --id "$WINDOW_ID"
  nvr --servername /tmp/main.sock --remote-expr "execute('$app_cmd $TARGET')"
fi


