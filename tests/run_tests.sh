#!/bin/sh
# Master Test Suite Runner

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================================="
echo "        Antigravity-Acode Unit & E2E Test Suite          "
echo "========================================================="
echo ""

FAIL_COUNT=0

run_test() {
    local name="$1"
    local path="$2"
    echo "Running: $name..."
    chmod +x "$path"
    if "$path"; then
        echo "--> [PASS] $name"
    else
        echo "--> [FAIL] $name"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo ""
}

run_test "1. Architecture Test" "$BASE_DIR/tests/test_arch.sh"
run_test "2. Installer Syntax Test" "$BASE_DIR/tests/test_installer.sh"
run_test "3. Launcher Execution Test" "$BASE_DIR/tests/test_launcher.sh"

echo "========================================================="
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "  SUMMARY: ALL TESTS PASSED [PASS]  "
    echo "========================================================="
    exit 0
else
    echo "  SUMMARY: $FAIL_COUNT TESTS FAILED [FAIL]  "
    echo "========================================================="
    exit 1
fi
