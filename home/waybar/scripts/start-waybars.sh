#!/usr/bin/env bash
set -euo pipefail

WAYBAR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
WATCH_SCRIPT="$WAYBAR_CONFIG_DIR/scripts/niri-window-watch.sh"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-start.pid"

if [[ -r "$PID_FILE" ]]; then
  read -r previous_pid < "$PID_FILE" || true
  if [[ "$previous_pid" =~ ^[0-9]+$ && "$previous_pid" != "$$" ]] && kill -0 "$previous_pid" 2>/dev/null; then
    kill -TERM "$previous_pid" 2>/dev/null || true
    for _ in {1..20}; do
      kill -0 "$previous_pid" 2>/dev/null || break
      sleep 0.1
    done
  fi
fi
printf '%s\n' "$$" > "$PID_FILE"

# This script is also used as a manual restart command. Remove an existing bar
# and its watcher first so repeated runs never accumulate duplicate instances.
# On Nix, the executable's process name is `.waybar-wrapped`, but its full
# command line remains simply `waybar`.
pkill -TERM -f -x 'waybar' 2>/dev/null || true
pkill -TERM -x '.waybar-wrapped' 2>/dev/null || true
pkill -TERM -f -- "$WATCH_SCRIPT" 2>/dev/null || true

for _ in {1..50}; do
  if niri msg --json workspaces >/dev/null 2>&1; then
    break
  fi

  sleep 0.1
done

waybar &
top_pid=$!

"$WATCH_SCRIPT" &
watch_pid=$!

cleanup() {
  kill "$top_pid" "$watch_pid" 2>/dev/null || true
  wait "$top_pid" "$watch_pid" 2>/dev/null || true
  if [[ "$(<"$PID_FILE" 2>/dev/null)" == "$$" ]]; then
    rm -f "$PID_FILE"
  fi
}

trap cleanup EXIT INT TERM
wait "$top_pid" "$watch_pid" || true
