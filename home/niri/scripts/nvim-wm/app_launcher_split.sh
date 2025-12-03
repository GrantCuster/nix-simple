#!/bin/sh

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <application> [args...]"
  echo "Example: $0 google-chrome-stable --ozone-platform=wayland"
  exit 1
fi

# Create a temporary file to store the captured ID
TEMP_FILE=$(mktemp)

# Start niri event stream in background and store the PID
niri msg --json event-stream | while IFS= read -r line; do
    WINDOW_ID=$(echo "$line" | jq -r 'select(.WindowOpenedOrChanged != null) | .WindowOpenedOrChanged.window.id')
    if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
        echo "$WINDOW_ID" > "$TEMP_FILE"
        break
    fi
done &
EVENT_PID=$!

sleep 0.1

# Launch the application with all provided arguments
"$@" &
LAUNCH_PID=$!

# Wait for the ID to be captured (check the temp file)
while [ ! -s "$TEMP_FILE" ]; do
    sleep 0.1
done

# Read the captured ID
NEW_WINDOW_ID=$(cat "$TEMP_FILE")

# Clean up temp file
rm "$TEMP_FILE"

# Kill the event stream background process
kill $PID 2>/dev/null

edit_cmd="edit ~/windows/$NEW_WINDOW_ID.app"

STATE_FILE="/tmp/nvim_focus_state"
focused=$(sed -n '1p' "$STATE_FILE" 2>/dev/null || echo "false")
vim_window_id=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "")

echo vim_window_id: "$vim_window_id"
niri msg action focus-window --id "$vim_window_id"

# Get window dimensions and calculate aspect ratio
winwidth=$(nvr --servername /tmp/main.sock --remote-expr "winwidth(0)")
winheight=$(nvr --servername /tmp/main.sock --remote-expr "winheight(0)")

# Adjust width for character aspect ratio (characters are roughly twice as tall as wide)
adjusted_width=$(echo "$winwidth * 0.5" | bc)

# Determine split direction based on aspect ratio
if [ $(echo "$adjusted_width > $winheight" | bc) -eq 1 ]; then
  split_cmd="vsplit"
else
  split_cmd="split"
fi

nvr --servername /tmp/main.sock --remote-expr "execute('$split_cmd')"
nvr --servername /tmp/main.sock --remote-expr "execute('$edit_cmd')"

