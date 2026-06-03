#!/usr/bin/env bash

focused_json=$(niri msg --json focused-window 2>/dev/null)
workspace_id=$(echo "$focused_json" | jq -r '.workspace_id // empty')
focused_id=$(echo "$focused_json" | jq -r '.id // empty')

[[ -z "$workspace_id" ]] && exit 0

niri msg --json windows 2>/dev/null | jq -r \
  --argjson wsid "$workspace_id" \
  --argjson fid "${focused_id:-0}" \
  '[.[] | select(.workspace_id == $wsid)] |
   sort_by(.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1]) |
   map(
     ((.title // "?") | if startswith("vim") then "Neovim" else . end | if length > 20 then .[0:20] + "…" else . end) as $label |
     if .id == $fid
     then "&gt;\($label)"
     else " \($label)"
     end
   ) |
   join("  ")'
