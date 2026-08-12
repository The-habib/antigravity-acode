#!/bin/sh
# Antigravity CLI for Acode Alpine Linux - Hardened Updater & Rollback Engine
# Usage: update.sh or agy-update

set -eu

BASE_DIR="${HOME}/.antigravity-acode"
BIN_DIR="${BASE_DIR}/bin"
MANIFEST_FILE="${BASE_DIR}/manifest.json"
MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_arm64.json"
LOCAL_BIN="${HOME}/.local/bin"
AGY_LAUNCHER="${LOCAL_BIN}/agy"

echo "========================================================="
echo "      Antigravity CLI Upstream Updater & Rollback       "
echo "========================================================="
echo ""

fetch_url() {
    local url="$1"
    local output_file="$2"

    case "$url" in
        https://*) ;;
        *)
            echo "Fatal Security Error: Download URL ($url) is not HTTPS. Download rejected." >&2
            exit 1
            ;;
    esac

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -4 -o "$output_file" "$url" || curl -fsSL -o "$output_file" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget --https-only -q -O "$output_file" "$url"
    else
        echo "Fatal Error: Neither curl nor wget is available for HTTPS download." >&2
        exit 1
    fi

    if [ ! -s "$output_file" ]; then
        echo "Fatal Error: Downloaded file from $url is empty." >&2
        exit 1
    fi
}

compute_sha512() {
    local file="$1"
    if command -v sha512sum >/dev/null 2>&1; then
        sha512sum "$file" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 512 "$file" | cut -d' ' -f1
    elif command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha512 "$file" | sed 's/.*= //'
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c "import hashlib, sys; print(hashlib.sha512(open(sys.argv[1],'rb').read()).hexdigest())" "$file"
    else
        echo "NO_SHA512_ENGINE"
    fi
}

verify_sha512() {
    local file="$1"
    local expected_hash="$2"

    case "$expected_hash" in
        [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*)
            if [ "${#expected_hash}" -ne 128 ]; then
                echo "Fatal Security Error: Expected SHA-512 hash length (${#expected_hash}) is invalid." >&2
                exit 1
            fi
            ;;
        *)
            echo "Fatal Security Error: Malformed SHA-512 hash format: '$expected_hash'." >&2
            exit 1
            ;;
    esac

    local calc_hash
    calc_hash="$(compute_sha512 "$file")"

    if [ "$calc_hash" = "NO_SHA512_ENGINE" ]; then
        echo "Fatal Security Error: Mandatory SHA-512 engine unavailable for update verification." >&2
        exit 1
    fi

    if [ "$calc_hash" != "$expected_hash" ]; then
        echo "Security Error: Checksum mismatch on update payload! Aborting update." >&2
        echo "Expected: $expected_hash" >&2
        echo "Calculated: $calc_hash" >&2
        exit 1
    fi
    echo "✓ Package SHA-512 checksum verified successfully."
}

if [ ! -f "${BIN_DIR}/antigravity" ]; then
    echo "Error: Antigravity is not currently installed. Run install.sh first." >&2
    exit 1
fi

CURRENT_VER="unknown"
if [ -x "$AGY_LAUNCHER" ]; then
    CURRENT_VER="$("$AGY_LAUNCHER" --version 2>/dev/null || echo "unknown")"
fi
echo "Current Installed Version: $CURRENT_VER"

echo "Querying Google Antigravity release server..."
STAGING_DIR="${BASE_DIR}/update_staging_$$"
mkdir -p "$STAGING_DIR"

cleanup_staging() {
    rm -rf "$STAGING_DIR" 2>/dev/null || true
}
trap cleanup_staging EXIT

MANIFEST_TMP="${STAGING_DIR}/manifest.json"
fetch_url "$MANIFEST_URL" "$MANIFEST_TMP"

parse_json() {
    local key="$1"
    sed -n 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$MANIFEST_TMP"
}

LATEST_VER="$(parse_json "version")"
LATEST_URL="$(parse_json "url")"
LATEST_SHA512="$(parse_json "sha512")"

echo "Latest Upstream Version:  ${LATEST_VER:-unknown}"

if [ "$CURRENT_VER" = "$LATEST_VER" ] && [ "${1:-}" != "--force" ]; then
    echo "✓ Antigravity CLI is already at the latest version ($CURRENT_VER)."
    exit 0
fi

echo "Staging upstream update..."
UPDATE_ARCHIVE="${STAGING_DIR}/agy_update.tar.gz"
fetch_url "$LATEST_URL" "$UPDATE_ARCHIVE"
verify_sha512 "$UPDATE_ARCHIVE" "$LATEST_SHA512"

tar -xzf "$UPDATE_ARCHIVE" -C "$STAGING_DIR" antigravity
VALIDATED_BIN="$STAGING_DIR/antigravity"
chmod +x "$VALIDATED_BIN"

# Test candidate binary in staging before replacing current working binary
LOADER="${BASE_DIR}/glibc/ld-linux-aarch64.so.1"
LIB_DIR="${BASE_DIR}/glibc"

TEST_OUT=""
if command -v proot >/dev/null 2>&1; then
    TEST_OUT="$(proot "$LOADER" --library-path "$LIB_DIR" "$VALIDATED_BIN" --version 2>&1 || true)"
else
    TEST_OUT="$("$LOADER" --library-path "$LIB_DIR" "$VALIDATED_BIN" --version 2>&1 || true)"
fi

if ! echo "$TEST_OUT" | grep -q -E "^[0-9]+\.[0-9]+"; then
    echo "Validation Failure: Candidate update binary failed verification test! Output: $TEST_OUT" >&2
    echo "Update aborted. Existing working binary preserved." >&2
    exit 1
fi

# Atomic Backup & Replacement
echo "Backup current binary..."
cp "${BIN_DIR}/antigravity" "${BIN_DIR}/antigravity.bak"

echo "Applying update..."
cp "$VALIDATED_BIN" "${BIN_DIR}/antigravity"

# Test live installation
if "$AGY_LAUNCHER" --version >/dev/null 2>&1; then
    echo "✓ Update verified! Successfully updated to version $LATEST_VER."
    rm -f "${BIN_DIR}/antigravity.bak" 2>/dev/null || true
    
    # Update manifest
    cat <<EOF > "$MANIFEST_FILE"
{
  "installed_version": "$LATEST_VER",
  "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "upstream_url": "$LATEST_URL",
  "sha512": "$LATEST_SHA512"
}
EOF
    exit 0
else
    echo "Error: Updated binary failed live launcher check. Initiating ROLLBACK..." >&2
    cp "${BIN_DIR}/antigravity.bak" "${BIN_DIR}/antigravity"
    rm -f "${BIN_DIR}/antigravity.bak" 2>/dev/null || true
    echo "✓ Rollback complete. Preserved working binary version $CURRENT_VER."
    exit 1
fi
