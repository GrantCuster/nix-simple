#!/bin/sh

# Assume we're in tmux
DIR="$HOME/notepad"
DATE="$(date +'%Y-%m-%d')"
FILENAME="$DATE.md"
SESSION_NAME="+_$DATE"

if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
fi

if [ ! -f "$DIR/$FILENAME" ]; then
    touch "$DIR/$FILENAME"
fi

# Allow for nesting
unset TMUX

# Function to create a new tmux session and run nvim
create_session() {
  tmux new-session -d -s "$SESSION_NAME" -n "notepad" 
  sleep 0
  tmux send-keys -t "$SESSION_NAME:notepad" "cd $DIR; nvim $FILENAME; tmux attach-session -t $SESSION_NAME"
}
#
# Check if session exists
if tmux list-sessions | grep -q "^$SESSION_NAME:"; then
  tmux attach-session -t "$SESSION_NAME"
else
  create_session
fi
