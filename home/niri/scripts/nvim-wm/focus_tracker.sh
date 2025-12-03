#!/bin/sh

# Track whether vim is focused or not based on window title starting with "vim -"
# Uses niri's event-stream to monitor focus changes in real-time
# State file format:
# Line 1: focused (true/false)
# Line 2: window_id (last known vim window)

STATE_FILE="/tmp/nvim_focus_state"

# Initialize state file with default values
printf "false\n" > "$STATE_FILE"

# Monitor niri event stream for window focus changes
niri msg --json event-stream | while IFS= read -r line; do
    # Parse the event type
    event_type=$(echo "$line" | jq -r 'keys[0]')

    # We're interested in WindowFocusChanged and WindowOpenedOrChanged events
    if [ "$event_type" = "WindowFocusChanged" ] || [ "$event_type" = "WindowOpenedOrChanged" ]; then
        # Get the focused window info
        focused_window=$(niri msg --json focused-window 2>/dev/null)

        if [ -n "$focused_window" ] && [ "$focused_window" != "null" ]; then
            title=$(echo "$focused_window" | jq -r '.title // ""')
            window_id=$(echo "$focused_window" | jq -r '.id // ""')

            echo "Focused window title: $title, ID: $window_id"

            # Check if title starts with "vim -"
            case "$title" in
                "vim -"*)
                    # Vim is focused - store the window ID and socket
                    printf "true\n%s\n" "$window_id" > "$STATE_FILE"
                    ;;
                *)
                    # Vim is not focused - change first line to false
                    printf "false\n%s\n" "$(sed -n '2p' "$STATE_FILE")" > "$STATE_FILE"
                   ;;
            esac
        else
            # No window focused - change first line to false
            printf "false\n%s\n" "$(sed -n '2p' "$STATE_FILE")" > "$STATE_FILE"
       fi
    fi
done
