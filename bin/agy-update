#!/bin/sh
# Antigravity CLI for Acode Alpine Linux - Updater & Rollback Engine
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
FETCH_JSON=""
if command -v curl >/dev/null 2>&1; then
    FETCH_JSON="$(curl -fsSL -m 15 "$MANIFEST_URL" || true)"
elif command -v wget >/dev/null 2>&1; then
    FETCH_JSON="$(wget -q -T 15 -O - "$MANIFEST_URL" || true)"
fi

if [ -z "$FETCH_JSON" ]; then
    echo "Error: Unable to connect to Google release server." >&2
    exit 1
fi

parse_json() {
    local key="$1"
    echo "$FETCH_JSON" | sed -n 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
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
STAGING_DIR="${BASE_DIR}/update_staging_$$"
mkdir -p "$STAGING_DIR"

cleanup_staging() {
    rm -rf "$STAGING_DIR" 2>/dev/null || true
}
trap cleanup_staging EXIT

UPDATE_ARCHIVE="${STAGING_DIR}/agy_update.tar.gz"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$UPDATE_ARCHIVE" "$LATEST_URL"
else
    wget -q -O "$UPDATE_ARCHIVE" "$LATEST_URL"
fi

if command -v sha512sum >/dev/null 2>&1; then
    CALC_SHA="$(sha512sum "$UPDATE_ARCHIVE" | cut -d' ' -f1)"
    if [ "$CALC_SHA" != "$LATEST_SHA512" ]; then
        echo "Security Error: Checksum mismatch on update payload! Aborting update." >&2
        exit 1
    fi
fi

tar -xzf "$UPDATE_ARCHIVE" -C "$STAGING_DIR" antigravity
chmod +x "$STAGING_DIR/antigravity"

# Test candidate binary before replacing
LOADER="${BASE_DIR}/glibc/ld-linux-aarch64.so.1"
LIB_DIR="${BASE_DIR}/glibc"

TEST_OUT=""
if command -v proot >/dev/null 2>&1; then
    TEST_OUT="$(proot "$LOADER" --library-path "$LIB_DIR" "$STAGING_DIR/antigravity" --version 2>&1 || true)"
else
    TEST_OUT="$("$LOADER" --library-path "$LIB_DIR" "$STAGING_DIR/antigravity" --version 2>&1 || true)"
fi

if ! echo "$TEST_OUT" | grep -q -E "^[0-9]+\.[0-9]+"; then
    echo "Validation Failure: Candidate update binary failed verification test! Output: $TEST_OUT" >&2
    echo "Update aborted. Existing working binary preserved." >&2
    exit 1
fi

# Atomic Backup & Replacement (Rollback capability)
echo "Backup current binary..."
cp "${BIN_DIR}/antigravity" "${BIN_DIR}/antigravity.bak"

echo "Applying update..."
cp "$STAGING_DIR/antigravity" "${BIN_DIR}/antigravity"

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
    echo "✓ Rollback complete. Preserved working binary version $CURRENT_VER."
    exit 1
fi
