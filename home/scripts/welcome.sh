#!/bin/bash

# clean up old tmux sessions
clean_tmux

chosen_pokemon=$(pokemon)
echo $chosen_pokemon

# Check if we're inside a tmux session
if [ -z "$TMUX" ]; then
    echo "Not in a tmux session. Starting a new tmux session named $session_name..."
    tmux new-session -s "$chosen_pokemon" -d
    tmux send-keys -t "$chosen_pokemon" "clear; oblique | pokemonsay --pokemon ${chosen_pokemon} --no-name" C-m
    tmux attach-session -t "$chosen_pokemon"    # Attach to the new session
else
    echo "Already in a tmux session."
fi
