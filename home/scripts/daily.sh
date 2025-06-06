#!/bin/bash

# Set the base directory for notes
NOTE_DIR="$HOME/daily"

# Create the directory if it doesn't exist
mkdir -p "$NOTE_DIR"

# Get today's date in YYYY-MM-DD format
TODAY=$(date +%F)

# Full path to today's note
NOTE_PATH="$NOTE_DIR/$TODAY.md"

# Check if the file already exists
if [ ! -f "$NOTE_PATH" ]; then
    # Get human-readable date (e.g., "Saturday, May 24, 2025")
    HUMAN_DATE=$(date +"%A, %B %e, %Y")
    echo "# $HUMAN_DATE

" > "$NOTE_PATH"
fi

# Open the note in nvim, move to end, and start insert mode
nvr "$NOTE_PATH"
# nvr --remote-send '<C-\><C-n>G$a'
