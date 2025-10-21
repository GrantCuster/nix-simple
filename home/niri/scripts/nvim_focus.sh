#!/bin/sh

# Usage: nvim_focus.sh <direction>
# direction: left, right, up, down

direction="$1"

case "$direction" in
  left)
    vim_cmd="h"
    ;;
  right)
    vim_cmd="l"
    ;;
  up)
    vim_cmd="k"
    ;;
  down)
    vim_cmd="j"
    ;;
  *)
    echo "Usage: $0 {left|right|up|down}"
    exit 1
    ;;
esac

niri msg action switch-focus-between-floating-and-tiling
nvr --serverlist | while read -r server; do
  nvr --servername "$server" --remote-expr "execute('wincmd $vim_cmd')"
done
