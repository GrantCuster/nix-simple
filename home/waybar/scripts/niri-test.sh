
#!/bin/sh

idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
num="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $idfocused)] | length")"
 

echo "$num"

