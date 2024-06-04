
#!/bin/sh

~/.config/tmux/tmux_split_pane.sh --smart
sleep 0
tmux send-keys "tmux_notepad" C-m
