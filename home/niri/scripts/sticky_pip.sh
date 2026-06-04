#!/usr/bin/env bash

set -u

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/niri-sticky-pip"
STATE_FILE="$STATE_DIR/window-id"
PID_FILE="$STATE_DIR/watcher.pid"
WIDTH="${STICKY_PIP_WIDTH:-420}"
HEIGHT="${STICKY_PIP_HEIGHT:-236}"
MARGIN="${STICKY_PIP_MARGIN:-24}"

mkdir -p "$STATE_DIR"

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a "Sticky PiP" "$1" "$2" -t 1800
}

focused_window_id() {
  niri msg -j focused-window 2>/dev/null | jq -r '.id // empty'
}

focused_workspace_ref() {
  niri msg -j workspaces 2>/dev/null | jq -r '.[] | select(.is_focused) | .idx' | head -n1
}

window_exists() {
  local id="$1"
  niri msg -j windows 2>/dev/null | jq -e --argjson id "$id" '.[] | select(.id == $id)' >/dev/null
}

window_size() {
  local id="$1"
  niri msg -j windows 2>/dev/null \
    | jq -r --argjson id "$id" '.[] | select(.id == $id) | .layout.window_size | @tsv'
}

output_size() {
  niri msg -j focused-output 2>/dev/null | jq -r '.logical | [.width, .height] | @tsv'
}

position_window() {
  local id="$1"
  local out_width out_height win_width win_height dx dy

  niri msg action move-window-to-floating --id "$id" >/dev/null 2>&1 || return 1
  niri msg action set-window-width --id "$id" "$WIDTH" >/dev/null 2>&1 || true
  niri msg action set-window-height --id "$id" "$HEIGHT" >/dev/null 2>&1 || true
  niri msg action center-window --id "$id" >/dev/null 2>&1 || true
  sleep 0.05

  read -r out_width out_height < <(output_size)
  read -r win_width win_height < <(window_size "$id")

  win_width="${win_width:-$WIDTH}"
  win_height="${win_height:-$HEIGHT}"

  dx=$(awk -v ow="$out_width" -v ww="$win_width" -v m="$MARGIN" 'BEGIN { printf "%d", ((ow - ww) / 2) - m }')
  dy=$(awk -v oh="$out_height" -v wh="$win_height" -v m="$MARGIN" 'BEGIN { printf "%d", ((oh - wh) / 2) - m }')

  niri msg action move-floating-window --id "$id" -x "+$dx" -y "+$dy" >/dev/null 2>&1 || true
}

stop_watcher() {
  if [ -f "$PID_FILE" ]; then
    local pid
    pid=$(cat "$PID_FILE" 2>/dev/null || true)
    if [ -n "${pid:-}" ]; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
  fi

  rm -f "$STATE_FILE" "$PID_FILE"
}

restore_tiling() {
  local id="${1:-}"

  [ -n "$id" ] || id=$(focused_window_id)
  [ -n "$id" ] || return 0
  window_exists "$id" || return 0

  niri msg action move-window-to-tiling --id "$id" >/dev/null 2>&1 || true
  niri msg action set-window-width --id "$id" "50%" >/dev/null 2>&1 || true
  niri msg action reset-window-height --id "$id" >/dev/null 2>&1 || true
}

disable_pip() {
  local id

  id=$(cat "$STATE_FILE" 2>/dev/null || true)
  stop_watcher
  restore_tiling "$id"
}

move_to_focused_workspace() {
  local id="$1"
  local workspace

  window_exists "$id" || return 1

  workspace=$(focused_workspace_ref)
  [ -n "$workspace" ] || return 0

  niri msg action move-window-to-workspace --window-id "$id" --focus false "$workspace" >/dev/null 2>&1 || true
}

watch_window() {
  local id="$1"

  niri msg -j event-stream 2>/dev/null | while read -r event; do
    [ "$(cat "$STATE_FILE" 2>/dev/null || true)" = "$id" ] || exit 0

    case "$event" in
      *WorkspaceActivated*)
        move_to_focused_workspace "$id" || exit 0
        ;;
    esac
  done
}

case "${1:-toggle}" in
  watch)
    watch_window "$2"
    ;;
  stop)
    disable_pip
    notify "Disabled" "Sticky picture-in-picture is off."
    ;;
  toggle)
    id=$(focused_window_id)
    if [ -z "$id" ]; then
      notify "No focused window" "Focus a window before toggling sticky PiP."
      exit 1
    fi

    if [ "$(cat "$STATE_FILE" 2>/dev/null || true)" = "$id" ]; then
      disable_pip
      notify "Disabled" "Sticky picture-in-picture is off."
      exit 0
    fi

    stop_watcher
    echo "$id" > "$STATE_FILE"
    position_window "$id"
    move_to_focused_workspace "$id"
    "$0" watch "$id" >/tmp/niri-sticky-pip.log 2>&1 &
    echo "$!" > "$PID_FILE"
    notify "Enabled" "Focused window is now sticky PiP."
    ;;
  *)
    echo "Usage: $0 [toggle|stop|watch WINDOW_ID]" >&2
    exit 2
    ;;
esac
