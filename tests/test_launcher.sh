#!/bin/sh
# Unit Test: Launcher Execution & Argument Forwarding

set -u

AGY_LAUNCHER="${HOME}/.local/bin/agy"

if [ ! -x "$AGY_LAUNCHER" ]; then
    echo "[WARN] Launcher $AGY_LAUNCHER not currently installed."
    exit 0
fi

echo "Testing launcher --version argument forwarding..."
VER_OUT="$("$AGY_LAUNCHER" --version 2>&1 || true)"
if echo "$VER_OUT" | grep -q -E "^[0-9]+\.[0-9]+"; then
    echo "[PASS] Launcher successfully executed real binary and returned version: $VER_OUT"
    exit 0
else
    echo "[FAIL] Launcher execution returned: $VER_OUT"
    exit 1
fi
