#!/bin/sh

# File path
FILE=~/nix/home/niri/config.kdl

# Temporary file for processing
TMP_FILE=$(mktemp)

# Replace logic
if grep -q 'default-column-width { proportion 0.5; }' "$FILE"; then
    sed 's/default-column-width { proportion 0.5; }/default-column-width { proportion 0.3333; }/' "$FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$FILE"
    echo "Updated 0.5 to 0.3333."
elif grep -q 'default-column-width { proportion 0.3333; }' "$FILE"; then
    sed 's/default-column-width { proportion 0.3333; }/default-column-width { proportion 0.5; }/' "$FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$FILE"
    echo "Updated 0.3333 to 0.5."
else
    echo "No matching line found or already up-to-date."
fi

# Clean up temporary file
[ -e "$TMP_FILE" ] && rm "$TMP_FILE"
