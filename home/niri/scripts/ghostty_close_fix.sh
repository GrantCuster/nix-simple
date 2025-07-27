#!/bin/sh

action=$(niri msg -j focused-window | jq -r '.app_id')
if [ "$action" = "com.mitchellh.ghostty" ]; then
  pid=$(niri msg -j focused-window | jq -r '.pid')
  kill "$pid"
else
    niri msg action close-window
fi
