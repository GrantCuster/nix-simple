#!/bin/sh

ghostty -e "nvim ~/todo/TODO.md" & sleep 0.1 && ghostty -e "nvim -c 'terminal daily'"
