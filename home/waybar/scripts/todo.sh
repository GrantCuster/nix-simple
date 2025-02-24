#!/bin/bash

TODO_FILE="$HOME/todo/TODO.md"

if [[ -f "$TODO_FILE" ]]; then
  TODO_ITEM=$(grep -m1 '^- \[ \]' "$TODO_FILE" | sed 's/^- \[ \] //')
  echo "$TODO_ITEM"
else
  echo ""
fi
