#!/bin/bash

read -p "Commit message: " message
git commit -m "$message"
