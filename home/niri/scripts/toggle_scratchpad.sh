#!/bin/sh

WORKSPACE_NAME=$1
WINDOW_ID=$(cat /tmp/$WORKSPACE_NAME-window)
CURRENT_WORKSPACE=$(niri msg -j workspaces | jq '.[] | select(.is_focused) | .id')
CURRENT_WORKSPACE_IDX=$(niri msg -j workspaces | jq '.[] | select(.is_focused) | .idx')
WINDOWS=$(niri msg -j windows | jq --argjson ws "$CURRENT_WORKSPACE" '.[] | select(.workspace_id == $ws) | .id')
WORKSPACE_ID=$(niri msg -j workspaces | jq --arg ws "$WORKSPACE_NAME" '.[] | select(.name == $ws) | .id')

main() {
    if echo "$WINDOWS" | grep -q "$WINDOW_ID"; then
        echo "Moving window to scratchpad"
        niri msg action focus-window --id $WINDOW_ID
        niri msg action move-window-to-workspace $WORKSPACE_ID
        niri msg action focus-workspace $CURRENT_WORKSPACE_IDX
    else
        echo "Moving window to workspace"
        niri msg action focus-window --id $WINDOW_ID
        niri msg action move-window-to-workspace $CURRENT_WORKSPACE_IDX
    fi
}
main
