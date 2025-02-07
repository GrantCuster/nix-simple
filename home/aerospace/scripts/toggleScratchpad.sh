#!/usr/bin/env bash

set -euo pipefail

APP_ID=$(cat /tmp/scratchpad-window)
CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

main() {
    if aerospace list-windows --workspace "$CURRENT_WORKSPACE" --format "%{window-id}" | grep -q "$APP_ID"; then
        aerospace move-node-to-workspace NSP --window-id "$APP_ID"
    else
        aerospace move-node-to-workspace "$CURRENT_WORKSPACE" --window-id "$APP_ID" --focus-follows-window
    fi
}
main
