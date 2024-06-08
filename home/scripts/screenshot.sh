#!/bin/bash

export XDG_SCREENSHOTS_DIR="$HOME/Screenshots"

if [ ! -d "$XDG_SCREENSHOTS_DIR" ]; then
    mkdir -p "$XDG_SCREENSHOTS_DIR"
fi

screen() {
  grimshot --notify savecopy output
}

window() {
  grimshot --notify savecopy window
}

area() {
  grimshot --notify savecopy area
}

# Main script logic
case "$1" in
  screen)
    screen
    ;;
  window)
    window
    ;;
  area)
    area
    ;;
  *)
    echo "Usage: $0 {screen|window|area}"
    exit 1
    ;;
esac
