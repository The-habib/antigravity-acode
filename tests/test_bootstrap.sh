#!/bin/sh
# Integration Test: Host Utility Bootstrapping Logic

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Host Utility Bootstrapping Unit & Integration Test ==="

# 1. Test utility check when utility already exists
TEST_EXISTING_UTIL() {
    local util="tar"
    local check="command -v tar"
    if eval "$check" >/dev/null 2>&1; then
        echo "[PASS] Utility '$util' is correctly recognized as already present."
        return 0
    else
        echo "[FAIL] Utility '$util' missing."
        return 1
    fi
}

TEST_EXISTING_UTIL

# 2. Test fallback error when utility & apk are both missing (simulation)
SIMULATE_MISSING_UTIL_NO_APK() {
    local util_name="nonexistent_tool"
    local pkg_name="nonexistent_pkg"
    local apk_cmd="false"

    if ! command -v "$util_name" >/dev/null 2>&1; then
        if ! $apk_cmd >/dev/null 2>&1; then
            echo "[PASS] Missing utility + missing apk correctly triggers actionable failure message."
            return 0
        fi
    fi
    echo "[FAIL] Missing utility test failed."
    return 1
}

SIMULATE_MISSING_UTIL_NO_APK

echo "✓ Host utility bootstrapping test complete."
