#!/usr/bin/env bash

signal_ready_waybars() {
  local signal="$1"

  pgrep -x waybar | while IFS= read -r pid; do
    local age
    age="$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')"

    if [[ "$age" =~ ^[0-9]+$ && "$age" -ge 2 ]]; then
      kill "-$signal" "$pid" 2>/dev/null || true
    fi
  done
}

niri msg --json event-stream | while IFS= read -r line; do
  if echo "$line" | grep -qE 'Window'; then
    signal_ready_waybars RTMIN+8
    signal_ready_waybars RTMIN+9
  fi
done
