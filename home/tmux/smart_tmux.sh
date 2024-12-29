#!/bin/bash

# Function to start or switch to a tmux session
tmux_session() {
  if tmux has-session -t "$1" 2>/dev/null; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$1"
    else
      tmux attach-session -t "$1"
    fi
  else
    tmux new-session -d -s "$1" "nvim ."
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$1"
    else
      tmux attach-session -t "$1"
    fi
  fi
}

# Check if at least one argument was passed
if [ $# -gt 0 ]; then
  tmux_session "$1"
  exit
fi

home_dir="$HOME"
current_dir="$(pwd)"

if [ "$current_dir" = "$home_dir" ]; then
  session_name="home"
else
  session_name="$(basename "$current_dir")"
fi

tmux_session "$session_name"
