#!/bin/sh

STATE_FILE="/tmp/nvim_focus_state"
vim_focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

// maybe not?

# Get window dimensions and calculate aspect ratio
winwidth=$(nvr --servername /tmp/main.sock --remote-expr "winwidth(0)")
winheight=$(nvr --servername /tmp/main.sock --remote-expr "winheight(0)")

# Adjust width for character aspect ratio (characters are roughly twice as tall as wide)
adjusted_width=$(echo "$winwidth * 0.5" | bc)

# Determine split direction based on aspect ratio
if [ $(echo "$adjusted_width > $winheight" | bc) -eq 1 ]; then
  split_cmd="vsplit"
else
  split_cmd="split"
fi

if [ "$vim_focused" == "false" ]; then
  current_window_id=$(niri msg -j focused-window | jq -r '.id')

  # Move current window to "store" workspace
  niri msg action move-window-to-workspace --focus false "store"
  niri msg action set-window-width --id "$current_window_id" proportion 0.5
  niri msg action set-window-height --id "$current_window_id" proportion 1
  niri msg action move-window-to-tiling --id "$current_window_id"

  nvr --servername /tmp/main.sock --remote-expr "execute('noautocmd silent! $split_cmd | WindowSwitcher')"

  niri msg action focus-window --id "$vim_window_id"
else
  nvr --servername /tmp/main.sock --remote-expr "execute('noautocmd silent! $split_cmd | WindowSwitcher')"
fi
