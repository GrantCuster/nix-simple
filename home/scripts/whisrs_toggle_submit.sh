#!/usr/bin/env bash
set -euo pipefail

# Connector names change when displays are unplugged or reconnected. Resolve the
# Dell by its EDID identity rather than relying on its current DP-* connector.
dell_output() {
  niri msg --json outputs | jq --raw-output '
    to_entries[]
    | select(
        .value.make == "Dell Inc."
        and .value.model == "DELL P2421"
        and .value.serial == "CW19L23"
      )
    | .key
  ' | head --lines=1
}

terminal_app_id="com.mitchellh.ghostty"

notify_error() {
  notify-send "whisrs" "$1" 2>/dev/null || true
}

leftmost_terminal_id() {
  local target_output workspace_id
  target_output="$(dell_output)"
  [[ -n "$target_output" ]] || return 1

  workspace_id="$(
    niri msg --json workspaces | jq --raw-output --exit-status \
      --arg output "$target_output" '
        [.[] | select(.output == $output and .is_active)]
        | if length == 1 then .[0].id else error("expected one active workspace") end
      '
  )" || return 1

  niri msg --json windows | jq --raw-output --exit-status \
    --argjson workspace_id "$workspace_id" \
    --arg app_id "$terminal_app_id" '
      [
        .[]
        | select(
            .workspace_id == $workspace_id
            and .app_id == $app_id
            and .is_floating == false
            and .layout.pos_in_scrolling_layout != null
          )
      ]
      | sort_by(.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1])
      | if length > 0 then .[0].id else error("no tiled Ghostty window") end
    '
}

status="$(whisrs status 2>/dev/null || true)"

case "$status" in
  idle)
    if ! terminal_id="$(leftmost_terminal_id)"; then
      notify_error "No tiled Ghostty terminal on Dell's active workspace"
      exit 1
    fi

    if ! niri msg action focus-window --id "$terminal_id"; then
      notify_error "Couldn't focus the target terminal"
      exit 1
    fi

    # WHISRS captures the focused window when recording starts, then restores
    # it before it injects the transcription.
    sleep 0.1
    whisrs toggle
    exit 0
    ;;
  recording)
    whisrs toggle
    ;;
  transcribing)
    notify_error "Already transcribing; waiting for completion"
    exit 0
    ;;
  *)
    notify_error "Couldn't determine dictation state"
    exit 1
    ;;
esac

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

notify_error "Timed out waiting to submit transcription"
