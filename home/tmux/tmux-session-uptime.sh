#!/bin/bash
uptime=$(( $(date +%s) - $(tmux display-message -p '#{session_created}') ))
days=$((uptime / 86400))
hours=$(( (uptime % 86400) / 3600 ))
minutes=$(( (uptime % 3600) / 60 ))

output=""
[ $days -gt 0 ] && output="${output}${days}d"
[ $hours -gt 0 ] && output="${output}${hours}h"
[ $minutes -gt 0 ] && output="${output}${minutes}m"
[ $days -eq 0 ] && [ $hours -eq 0 ] && [ $minutes -eq 0 ] && output="0m"

echo "$output"
