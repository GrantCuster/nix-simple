#!/usr/bin/env bash

aerospace layout floating
~/.config/aerospace/scripts/centerWindow.sh
# get part before first |
echo $(aerospace list-windows --focused --format "%{window-id}") > /tmp/scratchpad-window
aerospace move-node-to-workspace NSP --window-id $(cat /tmp/scratchpad-window)

