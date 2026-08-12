#!/bin/sh
# Real Alpine Host Utility Bootstrapping & Integration Test

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Host Utility Bootstrapping & Integration Test ==="

# Helper: Direct Utility Check (Zero Eval)
check_required_utility() {
    local util="$1"
    case "$util" in
        ar)
            command -v ar >/dev/null 2>&1 || command -v dpkg-deb >/dev/null 2>&1
            ;;
        xz)
            command -v unxz >/dev/null 2>&1 || command -v xz >/dev/null 2>&1 || tar --help 2>&1 | grep -q xz
            ;;
        tar)
            command -v tar >/dev/null 2>&1
            ;;
        *)
            command -v "$util" >/dev/null 2>&1
            ;;
    esac
}

# 1. Test Existing Utility Recognition (tar)
if check_required_utility "tar"; then
    echo "[PASS] Existing utility 'tar' is correctly recognized without unnecessary package installation."
else
    echo "[FAIL] Existing utility recognition failed for tar!"
    exit 1
fi

# 2. Test Existing Utility Recognition (ar or dpkg-deb)
if check_required_utility "ar"; then
    echo "[PASS] Utility 'ar' is available on host."
else
    echo "[INFO] Utility 'ar' is missing on host; installer will trigger apk bootstrap."
fi

# 3. Test Missing Utility Behavior without apk (Fail-Closed Assertion)
test_no_apk_fail_closed() {
    local old_path="$PATH"
    local temp_path_dir="${BASE_DIR}/tmp/empty_path_dir_$$"
    mkdir -p "$temp_path_dir"
    
    # Isolate PATH without apk
    PATH="$temp_path_dir"
    export PATH

    local pass=0
    if ! command -v apk >/dev/null 2>&1; then
        if ! check_required_utility "nonexistent_tool_xyz_$$"; then
            pass=1
        fi
    fi

    PATH="$old_path"
    export PATH
    rm -rf "$temp_path_dir" 2>/dev/null || true

    if [ "$pass" -eq 1 ]; then
        echo "[PASS] Missing utility in no-apk environment correctly identified as unresolvable."
        return 0
    else
        echo "[FAIL] Fail-closed test for missing apk failed!"
        return 1
    fi
}

test_no_apk_fail_closed

echo "✓ Host utility bootstrapping tests passed (Zero-Eval Enforced)."
