#!/usr/bin/env bash
set -euo pipefail

pwd
ls -l ~/nix/nixos/extras/blocklist.txt
realpath ~/nix/nixos/extras/blocklist.txt

# Paths
ROOT="/home/grant/nix/nixos"
EXTRAS="$ROOT/extras"
BLOCK_FILE="$EXTRAS/blocklist.txt"
FOCUS_FILE="$EXTRAS/focus-block.nix"
STATE_FILE="$EXTRAS/focus-state"

generate_nix_block() {
  local useBlocklist=${1:-true}
  echo "{ ... }: {"
  echo "  networking.networkmanager = {"
  echo "    enable = true;"
  echo "  };"
  echo "  networking.extraHosts = ''"
  if [ "$useBlocklist" = true ]; then
    while read -r domain; do
      [[ -z "$domain" || "$domain" =~ ^# ]] && continue
      # IPv4 loopback
      echo "      127.0.1.1 $domain"
      # IPv6 loopback
      echo "      ::1 $domain"
    done < "$BLOCK_FILE"
  fi
  echo "  '';"
  echo "}"
}

case "${1:-}" in
  on)
    echo "🔒 Enabling focus mode..."
    generate_nix_block true > "$FOCUS_FILE"
    echo "on" > "$STATE_FILE"
    sudo nixos-rebuild switch --flake ~/nix#framework
    ;;
  off)
    echo "🔓 Disabling focus mode..."
    generate_nix_block false > "$FOCUS_FILE"
    echo "off" > "$STATE_FILE"
    sudo nixos-rebuild switch --flake ~/nix#framework 
    ;;
  status)
    cat "$STATE_FILE" 2>/dev/null || echo "off"
    ;;
  *)
    echo "Usage: focus.sh {on|off|status}"
    ;;
esac
