#!/usr/bin/env bash
set -euo pipefail

output_json=$(niri msg --json focused-output 2>/dev/null || true)

if [[ -z "$output_json" || "$output_json" == "null" ]]; then
  jq -cn '{text: "Output ?", tooltip: "No focused output", class: "unknown"}'
  exit 0
fi

name=$(jq -r '.name // ""' <<<"$output_json")
make=$(jq -r '.make // ""' <<<"$output_json")
model=$(jq -r '.model // ""' <<<"$output_json")
serial=$(jq -r '.serial // ""' <<<"$output_json")

case "$name:$make:$model" in
  eDP-*:BOE:NE135A1M-NY1|eDP-*:BOE:*)
    label="Laptop"
    class="laptop"
    ;;
  DP-*:Dell\ Inc.:DELL\ P2421)
    label="Monitor"
    class="dell"
    ;;
  DP-*:Seiko\ Epson\ Corporation:EPSON\ PJ)
    label="Projector"
    class="projector"
    ;;
  *)
    label="${model:-${name:-Output}}"
    class="other"
    ;;
esac

tooltip="$name"
if [[ -n "$make$model$serial" ]]; then
  tooltip="$name - $make $model $serial"
fi

jq -cn \
  --arg text "$label" \
  --arg tooltip "$tooltip" \
  --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: $class}'
