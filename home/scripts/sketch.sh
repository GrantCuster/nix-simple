#!/bin/bash

sketchybar --set space.$(aerospace list-workspaces --focused) label="$1"
