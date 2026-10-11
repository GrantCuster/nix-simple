#!/usr/bin/env bash
set -euo pipefail

port="${CARTRIDGE_TRIGGER_PORT:-37391}"
curl --silent --show-error --fail -X POST "http://127.0.0.1:${port}/submit-scan" >/dev/null
