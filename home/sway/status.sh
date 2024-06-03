#!/bin/bash



date=$(TZ="America/New_York" date +"%Y-%m-%d %l:%M %p")

isRecordingState="/tmp/isRecordingState"

isRecording=$(cat $isRecordingState)
recordingLabel=""
if [ "$isRecording" == "true" ]; then
  recordingLabel=" 󰑊"
fi

echo "$recordingLabel$date"
