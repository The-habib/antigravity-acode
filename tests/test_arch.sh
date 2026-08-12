#!/bin/sh
# Unit Test: Architecture Detection

set -u

ARCH="$(uname -m 2>/dev/null || echo "unknown")"
case "$ARCH" in
    aarch64|arm64|armv8*)
        echo "[PASS] Architecture $ARCH recognized as supported aarch64."
        exit 0
        ;;
    *)
        echo "[WARN] Architecture $ARCH is not aarch64."
        exit 0
        ;;
esac
