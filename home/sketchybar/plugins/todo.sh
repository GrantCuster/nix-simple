#!/bin/bash

TODO_FILE="$HOME/dev/TODO.md"

if [[ -f "$TODO_FILE" ]]; then
  TODO_ITEM=$(grep -m1 '^- \[ \]' "$TODO_FILE" | sed 's/^- \[ \] //')

    sketchybar --set todo label="$TODO_ITEM"
else
    echo "TODO file not found."
fi
