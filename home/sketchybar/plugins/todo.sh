#!/bin/bash

TODO_FILE="$HOME/todo/TODO.md"

if [[ -f "$TODO_FILE" ]]; then
  TODO_ITEM=$(grep -m1 '^- \[ \]' "$TODO_FILE" | sed 's/^- \[ \] //')

  sketchybar --set todo label="$TODO_ITEM"
fi
