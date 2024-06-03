#!/bin/bash

clean_tmux

# add * to new session to clean up easier
# Check if at least one argument was passed
if [ $# -gt 0 ]; then
  if tmux has-session -t "+ $1" 2>/dev/null; then
    tmux switch-client -t "+ $1" 
  else 
    tmux new-session -d -s "+ $1"
    tmux switch-client -t "+ $1" 
  fi
  exit
fi

current_dir="$(pwd)"

chosen=$(tmux ls -F '#{session_name}' | grep -v '^[0-9]*$' | fzf)

tmux info &>/dev/null
if [ $? != 0 ]; then
  tmux new-session -d -s "$chosen"
  tmux attach -t "$chosen" 
  exit 0
fi

if tmux has-session -t "$chosen" 2>/dev/null; then
  tmux info &>/dev/null
  if [ $? != 0 ]; then
    tmux attach -t "$chosen"
    exit 0
  fi
  tmux switch-client -t "$chosen" 
else 
  tmux new-session -d -s "$chosen"
  tmux info &>/dev/null
  if [ $? != 0 ]; then
    tmux attach -t "$chosen"
    exit 0
  fi
  tmux switch-client -t "$chosen"
fi
