#!/bin/sh

# Move current window to "store" workspace
niri msg action move-window-to-workspace --focus false "store"

# Find the most recent nvim app tmp file and focus that window
TMP_FILE=$(ls -t /tmp/nvim_app.txt 2>/dev/null | head -n1)

if [ -n "$TMP_FILE" ] && [ -f "$TMP_FILE" ]; then
    # Extract window_id from the file
    WINDOW_ID=$(grep "^window_id=" "$TMP_FILE" | cut -d= -f2)
    SOCKET=$(grep "^socket=" "$TMP_FILE" | cut -d= -f2)

    if [ -n "$WINDOW_ID" ]; then
        niri msg action focus-window --id "$WINDOW_ID"
    fi

    # Close split
    # nvr --servername "$SOCKET" --remote-expr "execute('q')"
fi
