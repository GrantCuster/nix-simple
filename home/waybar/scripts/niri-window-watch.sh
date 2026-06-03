#!/usr/bin/env bash

niri msg --json event-stream | while IFS= read -r line; do
  if echo "$line" | grep -qE 'Window'; then
    pkill -RTMIN+8 waybar
    pkill -RTMIN+9 waybar
  fi
done
