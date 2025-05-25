
#!/bin/sh

idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
num="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $idfocused)] | length")"
 
symbol="."  # You can change this to any Unicode character you like
symbols=$(printf "%${num}s" | tr ' ' "$symbol")

echo "$symbols"
