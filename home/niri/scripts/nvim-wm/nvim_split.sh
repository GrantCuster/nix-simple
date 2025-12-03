#!/bin/sh

# Usage: nvim_split.sh <direction>
# direction: down, right

direction="$1"

case "$direction" in
  down)
    vim_cmd="vsplit"
    ;;
  right)
    vim_cmd="split"
    ;;
 *)
    echo "Usage: $0 {down|right}"
    exit 1
    ;;
esac

STATE_FILE="/tmp/nvim_focus_state"
vim_focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

if [ "$vim_focused" != "false" ] && [ -n "$vim_focused" ]; then
  nvr --servername /tmp/main.sock --remote-expr "execute('$vim_cmd')"
else
  # Find the most recent nvim app tmp file and focus that window
  niri msg action focus-window --id "$vim_window_id"
  nvr --servername /tmp/main.sock --remote-expr "execute('noautocmd silent! $vim_cmd | enew')"
fi


