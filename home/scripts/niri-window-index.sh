#!/usr/bin/env bash

focused=$(niri msg focused-window 2>/dev/null)
workspace_id=$(echo "$focused" | grep -oP 'Workspace ID: \K\d+')
focused_col=$(echo "$focused" | grep -oP 'column \K\d+')

total=$(niri msg windows 2>/dev/null | grep -c "Workspace ID: $workspace_id")

dots=""
for ((i=1; i<=total; i++)); do
  if [[ $i -eq $focused_col ]]; then
    dots+="●"
  else
    dots+="○"
  fi
done
echo "$dots"
