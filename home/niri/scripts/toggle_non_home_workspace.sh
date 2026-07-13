#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/niri"
STATE_FILE="$STATE_DIR/non-home-workspace-history"
LOCK_FILE="$STATE_DIR/non-home-workspace-history.lock"

focused_workspace() {
  niri msg -j workspaces 2>/dev/null \
    | jq -r '.[] | select(.is_focused) | @base64' \
    | head -n1
}

workspace_ref() {
  printf '%s' "$1" \
    | base64 -d \
    | jq -r 'if (.name // "") != "" then .name else (.idx | tostring) end'
}

workspace_name() {
  printf '%s' "$1" \
    | base64 -d \
    | jq -r '.name // ""'
}

read_state() {
  recent_ref=""
  older_ref=""

  if [ -f "$STATE_FILE" ]; then
    recent_ref="$(sed -n '1p' "$STATE_FILE")"
    older_ref="$(sed -n '2p' "$STATE_FILE")"
  fi
}

write_state() {
  mkdir -p "$STATE_DIR"
  tmp_file="$(mktemp "$STATE_DIR/non-home-workspace-history.XXXXXX")"
  {
    printf '%s\n' "$recent_ref"
    printf '%s\n' "$older_ref"
  } > "$tmp_file"
  mv "$tmp_file" "$STATE_FILE"
}

remember_non_home_workspace() {
  [ -n "$1" ] || return 0

  read_state

  if [ "$1" = "$recent_ref" ]; then
    return 0
  fi

  older_ref="$recent_ref"
  recent_ref="$1"
  write_state
}

remember_non_home_workspace_locked() {
  mkdir -p "$STATE_DIR"
  (
    flock -x 9
    remember_non_home_workspace "$1"
  ) 9>"$LOCK_FILE"
}

focus_workspace() {
  [ -n "$1" ] || return 1
  niri msg action focus-workspace "$1"
}

track_non_home_workspaces() {
  niri msg -j event-stream 2>/dev/null | while IFS= read -r _event; do
    focused="$(focused_workspace)"
    [ -n "$focused" ] || continue

    if [ "$(workspace_name "$focused")" != "home" ]; then
      remember_non_home_workspace_locked "$(workspace_ref "$focused")"
    fi
  done
}

if [ "${1:-}" = "--track" ]; then
  track_non_home_workspaces
  exit 0
fi

mkdir -p "$STATE_DIR"
exec 9>"$LOCK_FILE"
flock -x 9

focused="$(focused_workspace)"
[ -n "$focused" ] || exit 0

focused_ref="$(workspace_ref "$focused")"
focused_name="$(workspace_name "$focused")"

read_state

if [ "$focused_name" = "home" ]; then
  if focus_workspace "$recent_ref"; then
    exit 0
  fi

  niri msg action focus-workspace-previous
  sleep 0.05

  focused="$(focused_workspace)"
  [ -n "$focused" ] || exit 0

  if [ "$(workspace_name "$focused")" != "home" ]; then
    remember_non_home_workspace "$(workspace_ref "$focused")"
  fi

  exit 0
fi

remember_non_home_workspace "$focused_ref"
read_state

if [ -n "$older_ref" ] && [ "$older_ref" != "$focused_ref" ]; then
  focus_workspace "$older_ref"
  exit 0
fi

niri msg action focus-workspace-previous
sleep 0.05

focused="$(focused_workspace)"
[ -n "$focused" ] || exit 0

if [ "$(workspace_name "$focused")" = "home" ]; then
  focus_workspace "$recent_ref" || true
fi
