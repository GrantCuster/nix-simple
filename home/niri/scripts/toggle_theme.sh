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


NIRI_CONFIG="$HOME/.config/niri/config.kdl"

if [ "$MODE" = "dark" ]; then
  NEW="light"
  BG="#f9f5d7"
  FOCUS="#d5c4a1"
  BORDER="#ebdbb2"
else
  NEW="dark"
  BG="#1d2021"
  FOCUS="#928374"
  BORDER="#3c3836"
fi

sleep 0.25

# --- Update Niri config contextually ---
awk -v bg="$BG" -v focus="$FOCUS" -v border="$BORDER" '
  {
    if ($0 ~ /background-color/) {
      sub(/"#[0-9a-fA-F]+"/, "\"" bg "\"")
    }
    else if ($0 ~ /\/\/[[:space:]]*focus-color/) {
      getline
      sub(/"#[0-9a-fA-F]+"/, "\"" focus "\"")
      print "// focus-color"
      print
      next
    }
    else if ($0 ~ /\/\/[[:space:]]*border-color/) {
      getline
      sub(/"#[0-9a-fA-F]+"/, "\"" border "\"")
      print "// border-color"
      print
      getline
      sub(/"#[0-9a-fA-F]+"/, "\"" border "\"")
      print
      next
    }
    print
  }
' "$NIRI_CONFIG" > "$NIRI_CONFIG.tmp" && mv "$NIRI_CONFIG.tmp" "$NIRI_CONFIG"

echo "Switched to $NEW mode"
