#!/usr/bin/env bash

set -euo pipefail

focused_workspace_idx() {
  niri msg -j workspaces 2>/dev/null \
    | jq -r '.[] | select(.is_focused) | .idx // empty' \
    | head -n1
}

idx="$(focused_workspace_idx)"

if [ "$idx" = "1" ]; then
  niri msg action focus-workspace-previous
else
  niri msg action focus-workspace 1
fi
