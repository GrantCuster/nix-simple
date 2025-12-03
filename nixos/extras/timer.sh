#!/usr/bin/env bash

TIMER_STATE="$HOME/nix/nixos/extras/timer-state"

case "$1" in
  start)
    if [ ! -f "$TIMER_STATE" ] || [ "$(cat "$TIMER_STATE")" = "0" ]; then
      date +%s > "$TIMER_STATE"
      echo "Timer started"
    else
      echo "Timer already running"
    fi
    ;;
  stop)
    echo "0" > "$TIMER_STATE"
    echo "Timer stopped"
    ;;
  reset)
    echo "0" > "$TIMER_STATE"
    echo "Timer reset"
    ;;
  restart)
    date +%s > "$TIMER_STATE"
    echo "Timer restarted"
    ;;
  *)
    echo "Usage: $0 {start|stop|reset|restart}"
    exit 1
    ;;
esac
