#!/bin/bash

APP_NAME="Screen Recorder"
RECORDINGS_DIR="$HOME/visuals/recordings"
TMP_FILE="/tmp/recording_window.mp4"
PID_FILE="/tmp/recording_window.pid"
GAP=4

mkdir -p "$RECORDINGS_DIR"

STATUS_FILE="/tmp/rec_status"

is_recording() {
  [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

set_status() {
  echo "$1" > "$STATUS_FILE"
}

clear_status() {
  echo "" > "$STATUS_FILE"
}

get_focused_geometry() {
  local out_w out_h focused workspace_id focused_col win_w win_h tile_h tile_w

  out_w=$(niri msg --json outputs | jq 'to_entries[0].value.logical.width')
  out_h=$(niri msg --json outputs | jq 'to_entries[0].value.logical.height')

  focused=$(niri msg --json focused-window)
  workspace_id=$(echo "$focused" | jq '.workspace_id')
  focused_col=$(echo "$focused" | jq '.layout.pos_in_scrolling_layout[0]')
  win_w=$(echo "$focused"  | jq '.layout.window_size[0]')
  win_h=$(echo "$focused"  | jq '.layout.window_size[1]')
  tile_h=$(echo "$focused" | jq '.layout.tile_size[1]')
  tile_w=$(echo "$focused" | jq '.layout.tile_size[0]')

  # y: output_h - tile_h - bottom_gap
  local y
  y=$(awk "BEGIN { printf \"%d\", $out_h - $tile_h - $GAP }")

  # Get one tile_w per column for all columns on this workspace, sorted
  local col_widths
  col_widths=$(niri msg --json windows | jq -r \
    --argjson ws "$workspace_id" \
    '[.[] | select(.workspace_id == $ws)]
     | group_by(.layout.pos_in_scrolling_layout[0])
     | map({ col: .[0].layout.pos_in_scrolling_layout[0],
             w:   .[0].layout.tile_size[0] })
     | sort_by(.col)
     | .[] | "\(.col) \(.w)"')

  # Compute workspace_x of focused col by summing preceding column widths
  local workspace_x
  workspace_x=$(echo "$col_widths" | awk -v gap=$GAP -v fc=$focused_col '
    BEGIN { x = gap }
    {
      if ($1 == fc) { print x; exit }
      x += $2 + gap
    }
  ')

  # If focused col right edge exceeds screen width, scroll it into view from right
  local screen_x
  screen_x=$(awk -v wx="$workspace_x" -v tw="$tile_w" -v gap=$GAP -v ow="$out_w" 'BEGIN {
    right = wx + tw + gap
    offset = (right > ow) ? right - ow : 0
    sx = wx - offset
    printf "%d", (sx < 0) ? 0 : sx
  }')

  echo "$((screen_x + 1)),${y} $((win_w - 1))x$((win_h - 1))"
}

start() {
  local geometry
  geometry=$(get_focused_geometry)

  if [ -z "$geometry" ]; then
    exit 1
  fi

  set_status "REC"
  wf-recorder -g "$geometry" -f "$TMP_FILE" -c h264_vaapi -d /dev/dri/renderD128 &
  echo $! > "$PID_FILE"
  wait
}

stop() {
  if ! is_recording; then
    clear_status
    return
  fi
  kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
  if [ ! -f "$TMP_FILE" ]; then
    clear_status
    return
  fi
  set_status "PROCESSING"
  FILENAME="$RECORDINGS_DIR/$(date +"%Y-%m-%d_%H-%M-%S").mp4"
  ffmpeg -i "$TMP_FILE" \
    -c:v libx264 -crf 20 -preset slow \
    -pix_fmt yuv420p \
    -movflags +faststart \
    -vf "scale='trunc(iw/2)*2:trunc(ih/2)*2'" \
    -an \
    "$FILENAME" && rm "$TMP_FILE"
  clear_status
}

cancel() {
  if is_recording; then
    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    rm -f "$TMP_FILE"
    clear_status
  fi
}

case "${1:-toggle}" in
  cancel) cancel ;;
  *)      if is_recording; then stop; else start; fi ;;
esac
