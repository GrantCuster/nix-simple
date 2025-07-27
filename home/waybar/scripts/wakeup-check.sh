#!/usr/bin/env bash

current_time=$(date +%H:%M)

if [[ "$current_time" == "06:00" ]]; then
  wakeup
fi
