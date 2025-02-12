#!/bin/bash

TODO_FILE="$HOME/todo/TODO.md"

if [[ -f "$TODO_FILE" ]]; then
  # Find the line number of the marker (>)
  MARKER_LINE=$(grep -n '^START' "$TODO_FILE" | cut -d: -f1 | tail -n1)
  if [[ -n "$MARKER_LINE" ]]; then
    # Search for the first unchecked todo after the marker
    TODO_ITEM=$(tail -n +"$((MARKER_LINE + 1))" "$TODO_FILE" | grep -m1 '^- \[ \]' | sed 's/^- \[ \] //')
  else
    # Fallback to original behavior if no marker is found
    TODO_ITEM=$(grep -m1 '^- \[ \]' "$TODO_FILE" | sed 's/^- \[ \] //')
  fi

  sketchybar --set todo label="$TODO_ITEM"
fi
