#!/bin/sh

WORKSPACE_NAME=$1

# get current focused window id
# save it to tmp file

CURRENT_WORKSPACE=$(niri msg -j focused-window | jq -r '.workspace_id')
sh ~/.config/niri/scripts/center_floating_window.sh
ID=$(niri msg -j focused-window | jq -r '.id')
echo $ID > /tmp/$WORKSPACE_NAME-window
niri msg action move-window-to-workspace "$WORKSPACE_NAME"
niri msg action focus-workspace $CURRENT_WORKSPACE
