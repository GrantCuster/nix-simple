#!/usr/bin/env bash

focused=$(niri msg --json focused-window 2>/dev/null)
workspace_id=$(echo "$focused" | jq -r '.workspace_id // empty')
focused_col=$(echo "$focused" | jq -r '.layout.pos_in_scrolling_layout[0] // empty')

[[ -z "$workspace_id" ]] && exit 0

total=$(niri msg --json windows 2>/dev/null | jq "[.[] | select(.workspace_id == $workspace_id) | .layout.pos_in_scrolling_layout[0]] | unique | length")

dots=""
for ((i=1; i<=total; i++)); do
  if [[ $i -eq $focused_col ]]; then
    dots+="● "
  else
    dots+="○ "
  fi
done
echo "${dots% }"
