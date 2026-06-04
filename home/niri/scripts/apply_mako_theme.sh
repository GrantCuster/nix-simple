#!/usr/bin/env bash

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/theme-mode"
MODE=$(cat "$STATE_FILE" 2>/dev/null || echo "dark")

if [ "$MODE" != "light" ]; then
  MODE="dark"
fi

command -v makoctl >/dev/null 2>&1 || exit 0

if command -v mako >/dev/null 2>&1 && ! pgrep -x mako >/dev/null 2>&1; then
  mako >/tmp/mako.log 2>&1 &
  sleep 0.2
fi

makoctl reload >/dev/null 2>&1 || true
makoctl mode -s "$MODE" >/dev/null 2>&1 || true
