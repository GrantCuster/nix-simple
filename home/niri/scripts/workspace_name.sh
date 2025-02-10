#!/bin/sh

# Prompt for name
read -p "Name: " name

# Run command with the result
niri msg action set-workspace-name $name
