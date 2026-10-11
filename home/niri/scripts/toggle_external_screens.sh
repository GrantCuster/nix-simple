#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/niri"
STATE_FILE="$STATE_DIR/external-screens"
LAPTOP_OUTPUT_REGEX="${LAPTOP_OUTPUT_REGEX:-^(eDP|LVDS|DSI)-}"

usage() {
  printf 'Usage: %s [toggle|on|off|status]\n' "${0##*/}" >&2
}

outputs_json() {
  niri msg -j outputs
}

external_outputs() {
  jq -r --arg laptop_regex "$LAPTOP_OUTPUT_REGEX" '
    to_entries[]
    | select(.key | test($laptop_regex) | not)
    | .key
  '
}

laptop_outputs() {
  jq -r --arg laptop_regex "$LAPTOP_OUTPUT_REGEX" '
    to_entries[]
    | select(.key | test($laptop_regex))
    | select(.value.logical != null)
    | .key
  '
}

enabled_external_outputs() {
  jq -r --arg laptop_regex "$LAPTOP_OUTPUT_REGEX" '
    to_entries[]
    | select(.key | test($laptop_regex) | not)
    | select(.value.logical != null)
    | .key
  '
}

output_enabled() {
  local output="$1"

  outputs_json | jq -e --arg output "$output" '
    .[$output].logical != null
  ' >/dev/null
}

wait_for_output_enabled() {
  local output="$1"

  for _ in 1 2 3 4 5; do
    if output_enabled "$output"; then
      return 0
    fi
    sleep 0.2
  done

  return 1
}

save_outputs() {
  mkdir -p "$STATE_DIR"
  tmp_file="$(mktemp "$STATE_DIR/external-screens.XXXXXX")"
  printf '%s\n' "$@" > "$tmp_file"
  mv "$tmp_file" "$STATE_FILE"
}

saved_outputs() {
  if [ -s "$STATE_FILE" ]; then
    sed '/^[[:space:]]*$/d' "$STATE_FILE"
  fi
}

turn_off() {
  outputs="$(outputs_json)"
  mapfile -t connected_outputs < <(printf '%s' "$outputs" | external_outputs)
  mapfile -t enabled_outputs < <(printf '%s' "$outputs" | enabled_external_outputs)

  if [ "${#connected_outputs[@]}" -eq 0 ]; then
    notify-send "Displays" "No external screens are connected" 2>/dev/null || true
    return 0
  fi

  save_outputs "${connected_outputs[@]}"

  first_laptop="$(printf '%s' "$outputs" | laptop_outputs | head -n1)"
  if [ -n "$first_laptop" ]; then
    niri msg action focus-monitor "$first_laptop" >/dev/null 2>&1 || true
  fi

  for output in "${enabled_outputs[@]}"; do
    niri msg output "$output" off
  done

  notify-send "Displays" "External screens off: ${connected_outputs[*]}" 2>/dev/null || true
}

turn_on() {
  mapfile -t outputs < <(
    {
      saved_outputs
      outputs_json | external_outputs
    } | awk 'NF && !seen[$0]++'
  )

  if [ "${#outputs[@]}" -eq 0 ]; then
    notify-send "Displays" "No external screens to turn on" 2>/dev/null || true
    return 0
  fi

  failed_outputs=()
  for output in "${outputs[@]}"; do
    if ! niri msg output "$output" on || ! wait_for_output_enabled "$output"; then
      failed_outputs+=("$output")
    fi
  done

  if [ "${#failed_outputs[@]}" -gt 0 ]; then
    notify-send "Displays" "Failed to turn on: ${failed_outputs[*]}" 2>/dev/null || true
    printf 'Failed to turn on external screens: %s\n' "${failed_outputs[*]}" >&2
    printf 'Check Niri logs: journalctl --user -b -u niri.service\n' >&2
    return 1
  fi

  notify-send "Displays" "External screens on: ${outputs[*]}" 2>/dev/null || true
}

status() {
  outputs="$(outputs_json)"
  enabled_count="$(printf '%s' "$outputs" | enabled_external_outputs | wc -l)"
  connected="$(printf '%s' "$outputs" | external_outputs | paste -sd ' ' -)"

  if [ "$enabled_count" -gt 0 ]; then
    printf 'on'
  else
    printf 'off'
  fi

  if [ -n "$connected" ]; then
    printf ' (%s)' "$connected"
  fi

  printf '\n'
}

action="${1:-toggle}"

case "$action" in
  toggle)
    if [ "$(outputs_json | enabled_external_outputs | wc -l)" -gt 0 ]; then
      turn_off
    else
      turn_on
    fi
    ;;
  on)
    turn_on
    ;;
  off)
    turn_off
    ;;
  status)
    status
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac
