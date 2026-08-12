#!/bin/sh
# Security Unit & Protocol Regression Test Suite

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Security Unit & Protocol Regression Test ==="

# 1. Test Explicit --proto '=https' Enforcement
if grep -q -- "--proto '=https'" "$BASE_DIR/install.sh" && grep -q -- "--proto '=https'" "$BASE_DIR/update.sh"; then
    echo "[PASS] Explicit --proto '=https' protocol enforcement confirmed in install.sh & update.sh."
else
    echo "[FAIL] Insecure download: missing --proto '=https' in install.sh or update.sh!"
    exit 1
fi

# 2. Test TLS 1.2+ Enforcement
if grep -q -- "--tlsv1.2" "$BASE_DIR/install.sh" && grep -q -- "--tlsv1.2" "$BASE_DIR/update.sh"; then
    echo "[PASS] Explicit --tlsv1.2 minimum TLS version confirmed."
else
    echo "[FAIL] Missing --tlsv1.2 minimum TLS enforcement!"
    exit 1
fi

# 3. Test HTTP URL Rejection
if grep -q "http://" "$BASE_DIR/install.sh" "$BASE_DIR/update.sh"; then
    echo "[FAIL] Found insecure HTTP URL in install.sh or update.sh!"
    exit 1
else
    echo "[PASS] Zero insecure HTTP URLs found across installer and updater."
fi

# 4. Test Zero Eval Statements in installer/updater code
if grep -nE "^[[:space:]]*eval[[:space:]]" "$BASE_DIR/install.sh" "$BASE_DIR/update.sh" >/dev/null 2>&1; then
    echo "[FAIL] Found unsafe eval statement in install.sh or update.sh!"
    exit 1
else
    echo "[PASS] Zero eval execution statements found across installer and updater."
fi

# 5. Test Mandatory SHA-512 Engine Availability
if command -v sha512sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1 || command -v openssl >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
    echo "[PASS] Mandatory SHA-512 verification engine available."
else
    echo "[FAIL] No SHA-512 verification engine available."
    exit 1
fi

echo "✓ Security regression tests passed."
