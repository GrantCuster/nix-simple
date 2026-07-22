#!/bin/sh

set -eu

profile_dir="${XDG_STATE_HOME:-$HOME/.local/state}/capture-kiosk/chrome"
mkdir -p "$profile_dir"

exec google-chrome-stable \
  --ozone-platform=wayland \
  --user-data-dir="$profile_dir" \
  --password-store=basic \
  --hide-crash-restore-bubble \
  --kiosk \
  --app=https://capture.grantcuster.com/
