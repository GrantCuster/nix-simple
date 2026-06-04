#!/usr/bin/env bash

curl --max-time 1 -fsS http://127.0.0.1:36578/api/status 2>/dev/null |
  jq -r '.topActiveTodo.title // ""' 2>/dev/null
