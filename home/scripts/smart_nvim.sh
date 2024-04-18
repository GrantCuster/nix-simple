#!/bin/bash

# Check if an argument was supplied
if [ $# -eq 0 ]; then
	nvim .
else
	nvim "$1"
fi
