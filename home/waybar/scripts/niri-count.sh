
#!/bin/sh


# Function to get the number of windows in the focused workspace
get_window_count() {
    idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
    num="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $idfocused)] | length")"

    symbol="⬛"  # You can change this to any Unicode character you like
    symbols=$(printf "%${num}s" | tr ' ' "$symbol")

    echo "{\"text\": \"$symbols\", \"tooltip\": \"Windows in focused workspace: $num\"}"
}

# Initial output
get_window_count

# Listen for events and update output
niri msg event-stream | while read -r line; do
    case "$line" in
        "Window opened"*|"Window closed"*|"Workspace focused"*)
            get_window_count
            ;;
    esac
done

