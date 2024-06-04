#!/bin/bash

date=$(TZ="America/New_York" date +"%Y-%m-%d %l:%M %p")

isRecordingState="/tmp/isRecordingState"

recordingLabel=$(pgrep -x wf-recorder >/dev/null && echo "󰑊  " || echo "")

echo "$recordingLabel$date"
