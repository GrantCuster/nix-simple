#!/bin/bash

clean_tmux

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

current_dir="$(pwd)"

chosen=$(tmux ls -F '#{session_name}' | grep -v '^[0-9]*$' | fzf)
tmux switch-client -t "$chosen" 

