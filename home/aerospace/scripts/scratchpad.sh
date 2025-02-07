#!/usr/bin/env bash

set -euo pipefail

APP_ID="$1"
APP_NAME="$2"
CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

get_window_id() {
    aerospace list-windows --all --format "%{window-id}%{right-padding} | %{app-name}" |
    grep "$APP_NAME" |
    cut -d' ' -f1 |
    head -n1
}

focus_app() {
    local app_window_id
    app_window_id=$(get_window_id)
    aerospace move-node-to-workspace "$CURRENT_WORKSPACE" --window-id "$app_window_id"
    aerospace focus --window-id "$app_window_id"
}

is_app_closed() {
    ! aerospace list-windows --all --format '%{app-name}' | grep -q "$APP_NAME"
}

move_app_to_scratchpad() {
    local app_window_id
    app_window_id=$(aerospace list-windows --workspace "$CURRENT_WORKSPACE" --format "%{window-id}%{right-padding} | %{app-name}" |
                    grep "$APP_NAME" |
                    cut -d' ' -f1 |
                    head -n1)
    aerospace move-node-to-workspace NSP --window-id "$app_window_id"
}

main() {
    if is_app_closed; then
        open -a "$APP_NAME"
        sleep 0.5
    elif aerospace list-windows --workspace "$CURRENT_WORKSPACE" --format "%{app-bundle-id}" | grep -q "$APP_ID"; then
        move_app_to_scratchpad
    else
        focus_app
    fi
}
main
