#!/bin/bash

isRecordingState="/tmp/isRecordingState"

# Create a file to store the recording isRecordingState
if [ ! -f $isRecordingState ]; then
    touch $isRecordingState
fi

# Function to start recording
start_recording() {
  echo "Starting recording..."
  echo "true" > $isRecordingState
}

# Function to stop recording
stop_recording() {
  echo "Stopping recording..."
  echo "false" > $isRecordingState
}

# Main script logic
case "$1" in
  start)
    start_recording
    ;;
  stop)
    stop_recording
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
