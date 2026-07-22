#!/bin/bash

APP_NAME="Screen Recorder"
RECORDINGS_DIR="$HOME/visuals/recordings"
TMP_FILE="/tmp/recording_window.mp4"
PID_FILE="/tmp/recording_window.pid"
GAP=4
# Mirrors the "height" in waybar/bottom.jsonc; the bar sits below the tiles, so
# the tile bottom is this much higher than the bottom of the output.
BOTTOM_BAR=26

mkdir -p "$RECORDINGS_DIR"

STATUS_FILE="/tmp/rec_status"

is_recording() {
  [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

recording_pid() {
  [ -f "$PID_FILE" ] && cat "$PID_FILE"
}

set_status() {
  echo "$1" > "$STATUS_FILE"
}

clear_status() {
  echo "" > "$STATUS_FILE"
}

# wf-recorder scales the logical region by the output scale, and VAAPI's NV12
# encoder spins forever instead of erroring when a dimension lands on an odd
# number of physical pixels. Shrink to the nearest logical size that maps to an
# exact, even physical size (at 1.875 scale that means a multiple of 16).
snap_to_even_physical() {
  local dim="$1" scale="$2"

  awk -v d="$dim" -v s="$scale" 'BEGIN {
    for (i = d; i > 1; i--) {
      p = i * s
      r = int(p + 0.5)
      if (p - r < 1e-6 && r - p < 1e-6 && r % 2 == 0) { print i; exit }
    }
    print (d % 2 == 0) ? d : d - 1
  }'
}

get_focused_geometry() {
  local out_w out_h scale focused workspace_id focused_col win_w win_h tile_h tile_w

  out_w=$(niri msg --json outputs | jq 'to_entries[0].value.logical.width')
  out_h=$(niri msg --json outputs | jq 'to_entries[0].value.logical.height')
  scale=$(niri msg --json outputs | jq 'to_entries[0].value.logical.scale')

  focused=$(niri msg --json focused-window)
  workspace_id=$(echo "$focused" | jq '.workspace_id')
  focused_col=$(echo "$focused" | jq '.layout.pos_in_scrolling_layout[0]')
  win_w=$(echo "$focused"  | jq '.layout.window_size[0]')
  win_h=$(echo "$focused"  | jq '.layout.window_size[1]')
  tile_h=$(echo "$focused" | jq '.layout.tile_size[1]')
  tile_w=$(echo "$focused" | jq '.layout.tile_size[0]')

  # y: tiles are anchored above the bottom bar, not the bottom of the output
  local y
  y=$(awk "BEGIN { printf \"%d\", $out_h - $BOTTOM_BAR - $GAP - $tile_h }")

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

  local cap_w cap_h
  cap_w=$(snap_to_even_physical "$((win_w - 1))" "$scale")
  cap_h=$(snap_to_even_physical "$((win_h - 1))" "$scale")

  echo "$((screen_x + 1)),${y} ${cap_w}x${cap_h}"
}

start() {
  local geometry
  geometry=$(get_focused_geometry)

  if [ -z "$geometry" ]; then
    exit 1
  fi

  rm -f "$TMP_FILE"
  set_status "REC"
  wf-recorder -g "$geometry" -f "$TMP_FILE" -c h264_vaapi -d /dev/dri/renderD128 &
  echo $! > "$PID_FILE"
  wait
}

wait_for_recorder_to_stop() {
  local pid="$1"
  local tries="${2:-100}"

  local i
  for ((i = 0; i < tries; i++)); do
    if ! kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
    sleep 0.1
  done

  return 1
}

# wf-recorder only checks its quit flag between frames, so a recorder that is
# wedged before its first frame ignores INT and TERM. Escalate to KILL so a
# stuck recorder can never outlive the script and strand the PID file.
kill_recorder() {
  local pid="$1"

  kill -INT "$pid" 2>/dev/null
  wait_for_recorder_to_stop "$pid" 100 && return 0

  kill -TERM "$pid" 2>/dev/null
  wait_for_recorder_to_stop "$pid" 20 && return 0

  kill -KILL "$pid" 2>/dev/null
  wait_for_recorder_to_stop "$pid" 20
  return 1
}

stop() {
  if ! is_recording; then
    clear_status
    return
  fi

  local pid
  pid=$(recording_pid)

  local graceful=1
  kill_recorder "$pid" || graceful=0
  rm -f "$PID_FILE"

  # A force-killed recorder never wrote the mp4 trailer, so the file is unusable.
  if [ "$graceful" -eq 0 ]; then
    rm -f "$TMP_FILE"
    clear_status
    return 1
  fi

  if [ ! -s "$TMP_FILE" ]; then
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
    # kill succeeding only means the signal was delivered, so wait for the
    # process to actually die before dropping the PID file -- otherwise a
    # surviving recorder is orphaned and the next start stacks on top of it.
    kill_recorder "$(recording_pid)"
    rm -f "$TMP_FILE"
  fi

  rm -f "$PID_FILE"
  clear_status
}

case "${1:-toggle}" in
  cancel) cancel ;;
  *)      if is_recording; then stop; else start; fi ;;
esac
