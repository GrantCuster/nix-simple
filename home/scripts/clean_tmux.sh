#!/bin/bash

for session in $(tmux list-sessions -F "#{session_name}:#{session_attached}"); do
  session_name=$(echo $session | cut -d: -f1)
  session_attached=$(echo $session | cut -d: -f2)
  if [[ $session_name != \** ]] && [[ $session_attached == 0 ]]; then
    tmux kill-session -t "$session_name"
  fi
done