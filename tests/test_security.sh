#!/bin/sh
# Security Unit Test: HTTPS Enforcement & SHA-512 Mandatory Verification

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Security Unit Test ==="

# 1. Test HTTP URL Rejection in install.sh and update.sh
if grep -q "http://" "$BASE_DIR/install.sh" "$BASE_DIR/update.sh"; then
    echo "[FAIL] Found insecure HTTP URL in install.sh or update.sh!"
    exit 1
else
    echo "[PASS] Zero insecure HTTP URLs found across installer and updater."
fi

# 2. Test Mandatory SHA-512 Engine Availability
if command -v sha512sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1 || command -v openssl >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
    echo "[PASS] Mandatory SHA-512 verification engine available."
else
    echo "[FAIL] No SHA-512 verification engine available."
    exit 1
fi

# 3. Test Doctor Verification Enhancements
chmod +x "$BASE_DIR/bin/agy-doctor"
if "$BASE_DIR/bin/agy-doctor" >/dev/null 2>&1; then
    echo "[PASS] agy-doctor health check executed successfully."
else
    echo "[FAIL] agy-doctor reported failures."
    exit 1
fi

echo "✓ Security unit test passed."
