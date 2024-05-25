#!/bin/bash

# add * to new session to clean up easier

# Check if at least one argument was passed
if [ $# -gt 0 ]; then
  if tmux has-session -t "* $1" 2>/dev/null; then
    tmux switch-client -t "* $1" 
  else 
    tmux new-session -d -s "* $1"
    tmux switch-client -t "* $1" 
  fi
  exit
fi

home_dir="$HOME"
current_dir="$(pwd)"

if [ "$current_dir" = "$home_dir" ]; then
  chosen=$(tmux ls -F '#{session_name}' | grep -v '^[0-9]*$' | fzf)
  tmux switch-client -t "$chosen" 
else
  dir="$(basename "$current_dir")"
  echo "$dir"
  if tmux has-session -t "* $dir" 2>/dev/null; then
    tmux switch-client -t "* $dir" 
  else 
    tmux new-session -d -s "* $dir"
    tmux switch-client -t "* $dir" 
  fi
fi
