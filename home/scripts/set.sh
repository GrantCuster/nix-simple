#!/bin/bash

isRecordingState="/tmp/isRecordingState"

# Create a file to store the recording isRecordingState
if [ ! -f $isRecordingState ]; then
    touch $isRecordingState
fi
