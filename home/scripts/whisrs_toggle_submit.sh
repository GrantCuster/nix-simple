#!/usr/bin/env bash
set -euo pipefail

whisrs toggle

deadline=$((SECONDS + 60))
while (( SECONDS < deadline )); do
  status="$(whisrs status 2>/dev/null || true)"
  if [[ "$status" == "idle" ]]; then
    sleep 0.25
    printf 'key enter\n' | dotool
    exit 0
  fi
  sleep 0.1
done

notify-send "whisrs" "Timed out waiting to submit transcription" 2>/dev/null || true
