#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/theme-mode"
CONFIG_FILE="${NIRI_CONFIG_FILE:-$HOME/nix/home/niri/config.kdl}"
DARK_BACKGROUND="#1d2021"
LIGHT_BACKGROUND="#f9f5d7"
MODE=$(cat "$STATE_FILE" 2>/dev/null || echo "dark")

if [ "$MODE" = "dark" ]; then
  NEW="light"
  THEME="Gruvbox Light"
  BACKGROUND="$LIGHT_BACKGROUND"
  niri msg action do-screen-transition
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
else
  NEW="dark"
  THEME="Gruvbox Dark"
  BACKGROUND="$DARK_BACKGROUND"
  niri msg action do-screen-transition
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

sed -i -E "s/(^[[:space:]]*background-color[[:space:]]+\").*(\"[[:space:]]*$)/\1$BACKGROUND\2/" "$CONFIG_FILE"
niri msg action load-config-file

# --- Remember new mode
echo "$NEW" > "$STATE_FILE"

# --- Tell all active Neovim sessions (via nvr) to update
nvr --serverlist | while read -r server; do
  nvr --servername "$server" --remote-expr "v:lua.require('theme').apply('$NEW')" >/dev/null 2>&1
done

echo "Switched to $NEW mode"
