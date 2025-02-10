#!/bin/sh

niri msg action close-window
niri msg action unset-workspace-name
niri msg action focus-workspace $(niri msg -j workspaces | jq '.[] | select(.is_focused == true) | .idx - 1')
