
#!/bin/sh

# Log script execution for debugging
LOGFILE="/tmp/tmux_script_debug.log"
echo "Running script on $(date)" >> "$LOGFILE"

~/.config/tmux/tmux_split_pane.sh --smart >> "$LOGFILE" 2>&1

DIR="$HOME/notepad"
DATE="$(date +'%Y-%m-%d')"
FILENAME="$DATE.md"
SESSION_NAME="+_$DATE"

if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
    echo "Created directory: $DIR" >> "$LOGFILE"
fi

if [ ! -f "$DIR/$FILENAME" ]; then
    touch "$DIR/$FILENAME"
    echo "Created file: $DIR/$FILENAME" >> "$LOGFILE"
fi

echo "Made stuff" >> "$LOGFILE"

unset TMUX

# Function to create a new tmux session and run nvim
create_session() {
    tmux new-session -d -s "$SESSION_NAME" -n "notepad" -c "$DIR" >> "$LOGFILE" 2>&1
    tmux send-keys -t "$SESSION_NAME:0" "nvim '$FILENAME'" C-m >> "$LOGFILE" 2>&1
    tmux attach-session -t "$SESSION_NAME" >> "$LOGFILE" 2>&1
}
#
# Check if session exists
if tmux list-sessions | grep -q "^$SESSION_NAME:"; then
  echo "Session exists" >> "$LOGFILE"
  echo "Attaching to session" >> "$LOGFILE"
  echo "$SESSION_NAME" >> "$LOGFILE"
  tmux attach-session -t "$SESSION_NAME"
else
    create_session
fi

