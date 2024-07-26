#!/bin/bash

find . -maxdepth 1 -type d -printf "%Ts/%f\n" | sort -nr
