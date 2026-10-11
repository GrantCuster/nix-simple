#!/usr/bin/env bash

set -euo pipefail

native_screenshots_dir="$HOME/Pictures/Screenshots"
downloads_dir="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
marker_file="$(mktemp)"
temporary_file=""
temporary_metadata_file=""
capture_action="${1:-screenshot-window}"
focused_window="$(niri msg --json focused-window)"

cleanup() {
  rm -f "$marker_file" "$temporary_file" "$temporary_metadata_file"
}
trap cleanup EXIT

mkdir -p "$downloads_dir"
case "$capture_action" in
  screenshot|screenshot-screen|screenshot-window) ;;
  *)
    notify-send -u critical "Arranger" "Unsupported Niri screenshot action: $capture_action"
    exit 2
    ;;
esac

niri msg action "$capture_action"

for _attempt in {1..600}; do
  screenshot_file="$(find "$native_screenshots_dir" -maxdepth 1 -type f -name '*.png' -newer "$marker_file" -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | cut -d ' ' -f 2-)"
  if [[ -n "$screenshot_file" ]]; then
    metadata_file="$downloads_dir/arranger-window-${timestamp}.png.json"
    temporary_metadata_file="$(mktemp "$downloads_dir/.arranger-window-${timestamp}-XXXXXX.part")"
    jq -n \
      --arg capture_kind "$capture_action" \
      --arg captured_at "$(date --iso-8601=seconds)" \
      --arg title "$(jq -r '.title // ""' <<<"$focused_window")" \
      --arg app_id "$(jq -r '.app_id // ""' <<<"$focused_window")" \
      '{captureKind: $capture_kind, capturedAt: $captured_at, window: {title: $title, appId: $app_id}}' \
      > "$temporary_metadata_file"
    mv "$temporary_metadata_file" "$metadata_file"
    temporary_metadata_file=""
    temporary_file="$(mktemp "$downloads_dir/.arranger-window-${timestamp}-XXXXXX.part")"
    cp "$screenshot_file" "$temporary_file"
    mv "$temporary_file" "$downloads_dir/arranger-window-${timestamp}.png"
    temporary_file=""
    exit 0
  fi
  sleep 0.1
done

notify-send -u critical "Arranger" "Niri captured the window, but its screenshot file was not found."
exit 1
