#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/theme-mode"
MODE=$(cat "$STATE_FILE" 2>/dev/null || echo "dark")

if [ "$MODE" = "dark" ]; then
  NEW="light"
  THEME="Gruvbox Light"
  niri msg action do-screen-transition
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
else
  NEW="dark"
  THEME="Gruvbox Dark"
  niri msg action do-screen-transition
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

# --- Remember new mode
echo "$NEW" > "$STATE_FILE"

# --- Tell all active Neovim sessions (via nvr) to update
nvr --serverlist | while read -r server; do
  nvr --servername "$server" --remote-expr "v:lua.require('theme').apply('$NEW')" >/dev/null 2>&1
done

echo "Switched to $NEW mode"
