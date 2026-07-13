#!/usr/bin/env bash
set -euo pipefail

state="$(cat "$HOME/nix/nixos/extras/focus-state" 2>/dev/null || echo off)"

if [ "$state" = "on" ]; then
  printf '{"text":"FOCUS","tooltip":"Focus mode is on","class":"on"}\n'
else
  printf '{"text":"","tooltip":"Focus mode is off","class":"off"}\n'
fi
