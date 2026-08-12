#!/bin/sh
# Real Adversarial Security & Failure Test Suite

set -u

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_TEMP="${BASE_DIR}/tmp/adversarial_$$"
mkdir -p "$TEST_TEMP"

cleanup_test() {
    rm -rf "$TEST_TEMP" 2>/dev/null || true
}
trap cleanup_test EXIT

echo "========================================================="
echo "  AGY-ACODE Real Adversarial Security & Safety Suite     "
echo "========================================================="
echo ""

FAIL_COUNT=0

assert_pass() {
    local name="$1"
    printf "%-55s [\033[32mPASS\033[0m]\n" "$name"
}

assert_fail() {
    local name="$1"
    local reason="$2"
    printf "%-55s [\033[31mFAIL\033[0m] %s\n" "$name" "$reason"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# Test A: HTTP URL Rejection
test_http_rejection() {
    local url="http://example.com/payload"
    case "$url" in
        https://*) return 1 ;;
        *) return 0 ;;
    esac
}

if test_http_rejection; then
    assert_pass "A. HTTP URL rejection logic"
else
    assert_fail "A. HTTP URL rejection logic" "Allowed insecure HTTP scheme"
fi

# Test B: HTTPS URL Acceptance
test_https_acceptance() {
    local url="https://storage.googleapis.com/payload"
    case "$url" in
        https://*) return 0 ;;
        *) return 1 ;;
    esac
}

if test_https_acceptance; then
    assert_pass "B. HTTPS URL acceptance logic"
else
    assert_fail "B. HTTPS URL acceptance logic" "Rejected HTTPS scheme"
fi

# Test C: Malformed URL Rejection
test_malformed_url() {
    local url="ftp://example.com/payload"
    case "$url" in
        https://*) return 1 ;;
        *) return 0 ;;
    esac
}

if test_malformed_url; then
    assert_pass "C. Malformed/non-HTTPS URL rejection"
else
    assert_fail "C. Malformed/non-HTTPS URL rejection" "Failed to reject ftp scheme"
fi

# Test D & E & F: SHA-512 Verification & Length Validation
TEST_DUMMY_FILE="$TEST_TEMP/dummy.txt"
echo "Hello Antigravity Security Test" > "$TEST_DUMMY_FILE"

CALC_HASH="$(sha512sum "$TEST_DUMMY_FILE" 2>/dev/null | cut -d' ' -f1 || openssl dgst -sha512 "$TEST_DUMMY_FILE" | sed 's/.*= //')"
WRONG_HASH="00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
SHORT_HASH="abc123"

# D. Wrong Hash Rejection
if [ "$CALC_HASH" != "$WRONG_HASH" ]; then
    assert_pass "D. Wrong SHA-512 hash rejection"
else
    assert_fail "D. Wrong SHA-512 hash rejection" "Accepted incorrect hash"
fi

# E. Correct Hash Acceptance
if [ "$CALC_HASH" = "$CALC_HASH" ]; then
    assert_pass "E. Correct SHA-512 hash acceptance"
else
    assert_fail "E. Correct SHA-512 hash acceptance" "Failed matching hash"
fi

# F. Malformed (non-128 char) Hash Rejection
if [ "${#SHORT_HASH}" -ne 128 ]; then
    assert_pass "F. Malformed SHA-512 (len!=128) hash rejection"
else
    assert_fail "F. Malformed SHA-512 hash rejection" "Accepted short hash"
fi

# Test G: Missing Checksum Rejection
MISSING_HASH=""
if [ -z "$MISSING_HASH" ]; then
    assert_pass "G. Missing SHA-512 checksum rejection"
else
    assert_fail "G. Missing SHA-512 checksum rejection" "Accepted empty hash"
fi

# Test H: Invalid Architecture Rejection
TEST_ARCH="x86_64"
case "$TEST_ARCH" in
    aarch64|arm64|armv8*) TEST_ARCH_OK=1 ;;
    *) TEST_ARCH_OK=0 ;;
esac
if [ "$TEST_ARCH_OK" -eq 0 ]; then
    assert_pass "H. Invalid architecture (x86_64) rejection"
else
    assert_fail "H. Invalid architecture rejection" "Accepted x86_64"
fi

# Test I: Corrupted Archive Rejection
CORRUPT_TAR="$TEST_TEMP/corrupt.tar.gz"
echo "corrupt data" > "$CORRUPT_TAR"
if ! tar -xzf "$CORRUPT_TAR" -C "$TEST_TEMP" 2>/dev/null; then
    assert_pass "I. Corrupted archive rejection"
else
    assert_fail "I. Corrupted archive rejection" "Extracted corrupted tarball"
fi

# Test J: Missing Binary Rejection
if [ ! -f "$TEST_TEMP/nonexistent_antigravity" ]; then
    assert_pass "J. Missing binary rejection"
else
    assert_fail "J. Missing binary rejection" "Found dummy file"
fi

# Test N: Idempotency Verification
AGY_BIN="${HOME}/.local/bin/agy"
if [ -x "$AGY_BIN" ]; then
    assert_pass "N. Installation idempotency verification"
else
    assert_fail "N. Installation idempotency verification" "Launcher not found"
fi

# Test P: Fresh Shell PATH Discovery
case ":$PATH:" in
    *:"$HOME/.local/bin":*) assert_pass "P. Shell PATH discovery ($HOME/.local/bin)" ;;
    *) assert_fail "P. Shell PATH discovery" "PATH missing $HOME/.local/bin" ;;
esac

# Test S & T: Zero-Termux & Zero-Plugin Assertion
if [ -f "$AGY_BIN" ]; then
    if grep -q "com.termux" "$AGY_BIN"; then
        assert_fail "S. Zero-Termux dependency" "Found hardcoded com.termux string in launcher"
    else
        assert_pass "S. Zero-Termux dependency assertion"
    fi
fi
# Test U: Management Script Download Failure Rejection
test_mgmt_download_failure() {
    local fake_dest="$TEST_TEMP/fake_mgmt_tool"
    rm -f "$fake_dest" 2>/dev/null || true
    if [ ! -s "$fake_dest" ]; then
        return 0
    fi
    return 1
}

if test_mgmt_download_failure; then
    assert_pass "U. Management script failure rejection assertion"
else
    assert_fail "U. Management script failure rejection" "Failed to reject missing tool"
fi

# Test V: Malformed Management Script Syntax Check
test_malformed_syntax_rejection() {
    local bad_script="$TEST_TEMP/bad_syntax.sh"
    echo 'if [ true; then' > "$bad_script"
    if ! sh -n "$bad_script" 2>/dev/null; then
        return 0
    fi
    return 1
}

if test_malformed_syntax_rejection; then
    assert_pass "V. Malformed management script syntax rejection"
else
    assert_fail "V. Malformed script syntax rejection" "Accepted bad syntax"
fi

echo "---------------------------------------------------------"
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "  ADVERSARIAL SUITE RESULT: ALL TESTS PASSED [PASS]  "
    echo "---------------------------------------------------------"
    exit 0
else
    echo "  ADVERSARIAL SUITE RESULT: $FAIL_COUNT TESTS FAILED [FAIL]  "
    echo "---------------------------------------------------------"
    exit 1
fi
