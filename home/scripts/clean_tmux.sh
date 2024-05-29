#!/bin/bash

sessions=$(tmux list-sessions -F "#{session_name}:#{session_attached}")

for session in $sessions; do
  session_name=$(echo $session | cut -d: -f1)
  session_attached=$(echo $session | cut -d: -f2)
  if [[ $session_name != \+* ]] && [[ $session_attached == 0 ]]; then
    tmux kill-session -t "$session_name"
  fi
done
