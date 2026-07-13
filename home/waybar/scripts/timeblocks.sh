#!/usr/bin/env bash

set -euo pipefail

curl --max-time 1 -fsS http://127.0.0.1:48174/api/current 2>/dev/null |
  jq -c '
    if .current == null then
      {text: "", tooltip: ""}
    else
      .current as $current
      | (($current.progress // 0) * 100 | floor) as $percent
      | {
          text: "\($percent)% \($current.label)",
          tooltip: "\($current.range)\n\($current.source)",
          percentage: $percent
        }
    end
  ' 2>/dev/null || printf '{"text":"","tooltip":""}\n'
