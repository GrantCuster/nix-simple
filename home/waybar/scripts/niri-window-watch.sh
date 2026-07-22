#!/usr/bin/env bash

lock_file="${XDG_RUNTIME_DIR:-/tmp}/niri-window-watch.lock"
exec 9>"$lock_file"
flock -n 9 || exit 0

signal_ready_waybars() {
  local signal="$1"

  pgrep -f '^[w]aybar( |$)' | while IFS= read -r pid; do
    local age
    age="$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')"

    if [[ "$age" =~ ^[0-9]+$ && "$age" -ge 2 ]]; then
      kill "-$signal" "$pid" 2>/dev/null || true
    fi
  done
}

niri msg --json event-stream | while IFS= read -r line; do
  signal_ready_waybars RTMIN+8
  signal_ready_waybars RTMIN+9
  signal_ready_waybars RTMIN+10
done
