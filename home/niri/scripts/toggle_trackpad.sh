#!/bin/sh

FILE=~/nix/home/niri/config.kdl

# Use sed to toggle the line
sed -i -E 's/touchpad \{ off/touchpad { \/\/ off/;t; s/touchpad \{ \/\/ off/touchpad { off/' "$FILE"
