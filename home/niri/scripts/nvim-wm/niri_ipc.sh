#!/bin/sh

# niri_ipc.sh - Batch niri IPC actions over a single socket connection
# Usage: niri_ipc.sh '{"Action1": {...}}' '{"Action2": {...}}' ...
# Or via stdin: echo '{"Action": {...}}' | niri_ipc.sh

if [ -z "$NIRI_SOCKET" ]; then
    echo "Error: NIRI_SOCKET not set" >&2
    exit 1
fi

# Check if we have arguments or if we should read from stdin
if [ $# -eq 0 ]; then
    # Read from stdin
    while IFS= read -r action; do
        [ -n "$action" ] && set -- "$@" "$action"
    done
fi

# Exit if no actions provided
if [ $# -eq 0 ]; then
    echo "Error: No actions provided" >&2
    exit 1
fi

# Use socat to communicate with the socket
for action_json in "$@"; do
    # Wrap in Action envelope and send to socket
    wrapped=$(printf '{"Action":%s}\n' "$action_json")
    response=$(printf '%s' "$wrapped" | socat - "UNIX-CONNECT:$NIRI_SOCKET")

    # Check for errors in response
    if echo "$response" | grep -q '"Err"'; then
        echo "Error in action: $action_json" >&2
        echo "Response: $response" >&2
        exit 1
    fi
done

exit 0
