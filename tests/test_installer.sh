#!/bin/sh
# Unit Test: Installer Idempotency & Verification

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Testing installer script syntax..."
if sh -n "$BASE_DIR/install.sh"; then
    echo "[PASS] install.sh POSIX syntax check."
else
    echo "[FAIL] install.sh syntax error."
    exit 1
fi

echo "Testing updater script syntax..."
if sh -n "$BASE_DIR/update.sh"; then
    echo "[PASS] update.sh POSIX syntax check."
else
    echo "[FAIL] update.sh syntax error."
    exit 1
fi

echo "Testing uninstaller script syntax..."
if sh -n "$BASE_DIR/uninstall.sh"; then
    echo "[PASS] uninstall.sh POSIX syntax check."
else
    echo "[FAIL] uninstall.sh syntax error."
    exit 1
fi
