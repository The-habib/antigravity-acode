#!/bin/sh
# Unit Test: agy-setup Verification

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SETUP_SCRIPT="$BASE_DIR/bin/agy-setup"

if [ ! -f "$SETUP_SCRIPT" ]; then
    echo "[FAIL] agy-setup script missing."
    exit 1
fi

if sh -n "$SETUP_SCRIPT"; then
    echo "[PASS] agy-setup POSIX syntax check."
else
    echo "[FAIL] agy-setup syntax error."
    exit 1
fi

chmod +x "$SETUP_SCRIPT"
echo "✓ agy-setup test passed."
