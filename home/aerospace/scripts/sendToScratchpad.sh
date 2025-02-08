#!/usr/bin/env bash

TEMP_DIR=$1

aerospace layout floating
~/.config/aerospace/scripts/centerWindow.sh
# get part before first |
echo $(aerospace list-windows --focused --format "%{window-id}") > "/tmp/$TEMP_DIR-window"
aerospace move-node-to-workspace NSP --window-id $(cat "/tmp/$TEMP_DIR-window")
