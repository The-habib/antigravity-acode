#!/bin/sh
# Antigravity CLI for Acode Alpine Linux - Installer
# Repository: https://github.com/The-habib/antigravity-acode
# Usage: curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/install.sh | sh

set -eu

BASE_DIR="${HOME}/.antigravity-acode"
BIN_DIR="${BASE_DIR}/bin"
GLIBC_DIR="${BASE_DIR}/glibc"
STATE_DIR="${BASE_DIR}/state"
LOCAL_BIN="${HOME}/.local/bin"
MANIFEST_FILE="${BASE_DIR}/manifest.json"

MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_arm64.json"
GLIBC_DEB_URL="http://ftp.us.debian.org/debian/pool/main/g/glibc/libc6_2.36-9+deb12u14_arm64.deb"

echo "========================================================="
echo "  Google Antigravity CLI for Acode Alpine Linux Setup   "
echo "========================================================="
echo ""

# 1. Architecture Detection
echo "[1/7] Detecting system architecture..."
ARCH_RAW="$(uname -m 2>/dev/null || echo "unknown")"
case "$ARCH_RAW" in
    aarch64|arm64|armv8*)
        TARGET_ARCH="aarch64"
        echo "✓ Architecture confirmed: $TARGET_ARCH"
        ;;
    *)
        echo "Fatal Error: Unsupported architecture '$ARCH_RAW'." >&2
        echo "Antigravity-Acode currently supports aarch64 (ARM64) devices." >&2
        exit 1
        ;;
esac

# 2. Storage Execution Test
echo "[2/7] Testing home directory execution capability..."
mkdir -p "$BASE_DIR" "$BIN_DIR" "$GLIBC_DIR" "$STATE_DIR" "$LOCAL_BIN"
TEST_FILE="${BASE_DIR}/.exec_test_$$"
echo '#!/bin/sh' > "$TEST_FILE" 2>/dev/null
echo 'exit 0' >> "$TEST_FILE" 2>/dev/null
chmod +x "$TEST_FILE" 2>/dev/null
if ! "$TEST_FILE" 2>/dev/null; then
    rm -f "$TEST_FILE" 2>/dev/null || true
    echo "Fatal Error: Home directory ($HOME) partition prohibits execution (noexec)." >&2
    exit 1
fi
rm -f "$TEST_FILE" 2>/dev/null || true
echo "✓ Home directory execution verified."

# 3. Dynamic Upstream Release Discovery
echo "[3/7] Discovering current official Google Antigravity CLI release..."
STAGING_DIR="${BASE_DIR}/staging_$$"
mkdir -p "$STAGING_DIR"

cleanup_staging() {
    rm -rf "$STAGING_DIR" 2>/dev/null || true
}
trap cleanup_staging EXIT

FETCH_JSON=""
if command -v curl >/dev/null 2>&1; then
    FETCH_JSON="$(curl -fsSL -m 15 "$MANIFEST_URL" || true)"
elif command -v wget >/dev/null 2>&1; then
    FETCH_JSON="$(wget -q -T 15 -O - "$MANIFEST_URL" || true)"
fi

if [ -z "$FETCH_JSON" ]; then
    echo "Fatal Error: Could not reach Google release server ($MANIFEST_URL)." >&2
    echo "Please check your network and TLS certificate store." >&2
    exit 1
fi

# POSIX json value extraction
parse_json() {
    local key="$1"
    echo "$FETCH_JSON" | sed -n 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

UPSTREAM_VERSION="$(parse_json "version")"
UPSTREAM_URL="$(parse_json "url")"
UPSTREAM_SHA512="$(parse_json "sha512")"

if [ -z "$UPSTREAM_URL" ] || [ -z "$UPSTREAM_SHA512" ]; then
    echo "Fatal Error: Failed to parse release manifest from Google server." >&2
    exit 1
fi

echo "✓ Latest official release version: ${UPSTREAM_VERSION:-1.x.x}"

# 4. Download & Integrity Verification
echo "[4/7] Downloading official Antigravity binary package..."
AGY_ARCHIVE="${STAGING_DIR}/agy.tar.gz"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$AGY_ARCHIVE" "$UPSTREAM_URL"
else
    wget -q -O "$AGY_ARCHIVE" "$UPSTREAM_URL"
fi

if command -v sha512sum >/dev/null 2>&1; then
    CALC_SHA="$(sha512sum "$AGY_ARCHIVE" | cut -d' ' -f1)"
    if [ "$CALC_SHA" != "$UPSTREAM_SHA512" ]; then
        echo "Security Error: Checksum mismatch for downloaded Antigravity archive!" >&2
        echo "Expected: $UPSTREAM_SHA512" >&2
        echo "Actual:   $CALC_SHA" >&2
        exit 1
    fi
    echo "✓ Package SHA-512 checksum verified successfully."
fi

echo "Extracting official binary..."
tar -xzf "$AGY_ARCHIVE" -C "$STAGING_DIR" antigravity
cp "$STAGING_DIR/antigravity" "${BIN_DIR}/antigravity"
chmod +x "${BIN_DIR}/antigravity"

# 5. Glibc Runtime Acquisition & Extraction
echo "[5/7] Preparing isolated glibc dynamic runtime..."
GLIBC_DEB="${STAGING_DIR}/libc6.deb"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$GLIBC_DEB" "$GLIBC_DEB_URL" || curl -fsSL -o "$GLIBC_DEB" "http://ftp.us.debian.org/debian/pool/main/g/glibc/libc6_2.36-9+deb12u14_arm64.deb"
else
    wget -q -O "$GLIBC_DEB" "$GLIBC_DEB_URL"
fi

mkdir -p "${STAGING_DIR}/deb_extracted"
if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb -x "$GLIBC_DEB" "${STAGING_DIR}/deb_extracted"
else
    (cd "$STAGING_DIR" && ar x libc6.deb && tar -xf data.tar.xz -C "${STAGING_DIR}/deb_extracted")
fi

SRC_LIB=""
if [ -d "${STAGING_DIR}/deb_extracted/lib/aarch64-linux-gnu" ]; then
    SRC_LIB="${STAGING_DIR}/deb_extracted/lib/aarch64-linux-gnu"
elif [ -d "${STAGING_DIR}/deb_extracted/lib64" ]; then
    SRC_LIB="${STAGING_DIR}/deb_extracted/lib64"
else
    SRC_LIB="${STAGING_DIR}/deb_extracted/lib"
fi

cp -P "$SRC_LIB"/* "$GLIBC_DIR/" 2>/dev/null || cp "$SRC_LIB"/* "$GLIBC_DIR/"
chmod +x "$GLIBC_DIR"/ld-*.so* 2>/dev/null || true

# Shared library symlinks
(cd "$GLIBC_DIR" && \
 ln -sf libdl.so.2 libdl.so 2>/dev/null || true; \
 ln -sf libc.so.6 libc.so 2>/dev/null || true; \
 ln -sf libm.so.6 libm.so 2>/dev/null || true; \
 ln -sf libpthread.so.0 libpthread.so 2>/dev/null || true; \
 ln -sf libresolv.so.2 libresolv.so 2>/dev/null || true; \
 ln -sf librt.so.1 librt.so 2>/dev/null || true)

# Write manifest
cat <<EOF > "$MANIFEST_FILE"
{
  "installed_version": "$UPSTREAM_VERSION",
  "installed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "architecture": "$TARGET_ARCH",
  "upstream_url": "$UPSTREAM_URL",
  "sha512": "$UPSTREAM_SHA512"
}
EOF
echo "✓ Dynamic glibc runtime prepared."

# 6. Real Launcher Generation
echo "[6/7] Generating 'agy' launcher script..."
AGY_LAUNCHER="${LOCAL_BIN}/agy"

cat <<'LAUNCHER_EOF' > "$AGY_LAUNCHER"
#!/bin/sh
# Real Google Antigravity CLI Launcher for Acode Alpine Terminal

BASE_DIR="${HOME}/.antigravity-acode"
LOADER="${BASE_DIR}/glibc/ld-linux-aarch64.so.1"
LIB_DIR="${BASE_DIR}/glibc"
BINARY="${BASE_DIR}/bin/antigravity"

if [ ! -f "$LOADER" ] || [ ! -f "$BINARY" ]; then
    echo "Error: Antigravity installation corrupted. Run 'agy-doctor' or re-install." >&2
    exit 1
fi

# Dynamic DNS resolution fallback for glibc libresolv inside PRoot environments
DNS_BIND=""
if [ ! -f /etc/resolv.conf ]; then
    if [ -n "${PREFIX:-}" ] && [ -f "${PREFIX}/etc/resolv.conf" ]; then
        DNS_BIND="-b ${PREFIX}/etc/resolv.conf:/etc/resolv.conf"
    fi
fi

if [ -n "${PROOT_PID:-}" ] || grep -q -i "proot" /proc/1/cmdline 2>/dev/null; then
    exec "$LOADER" --library-path "$LIB_DIR" "$BINARY" "$@"
elif command -v proot >/dev/null 2>&1; then
    exec proot $DNS_BIND "$LOADER" --library-path "$LIB_DIR" "$BINARY" "$@"
else
    exec "$LOADER" --library-path "$LIB_DIR" "$BINARY" "$@"
fi
LAUNCHER_EOF

chmod +x "$AGY_LAUNCHER"

# Install management scripts if running from git checkout
SCRIPT_SOURCE_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_SOURCE_DIR" ] && [ -f "${SCRIPT_SOURCE_DIR}/bin/agy-doctor" ]; then
    cp "${SCRIPT_SOURCE_DIR}/bin/agy-doctor" "${LOCAL_BIN}/agy-doctor" 2>/dev/null || true
    cp "${SCRIPT_SOURCE_DIR}/bin/agy-update" "${LOCAL_BIN}/agy-update" 2>/dev/null || true
    chmod +x "${LOCAL_BIN}/agy-doctor" "${LOCAL_BIN}/agy-update" 2>/dev/null || true
fi

# 7. PATH Configuration
echo "[7/7] Configuring shell PATH persistence..."
PATH_EXPORT='export PATH="$HOME/.local/bin:$PATH"'
SHELL_FILES="${HOME}/.profile ${HOME}/.ashrc ${HOME}/.bashrc ${HOME}/.zshrc /initrc"

for sf in $SHELL_FILES; do
    if [ -f "$sf" ] || [ "$sf" = "${HOME}/.profile" ] || [ "$sf" = "/initrc" ]; then
        touch "$sf" 2>/dev/null || true
        if [ -w "$sf" ]; then
            if ! grep -q "\.local/bin" "$sf" 2>/dev/null; then
                echo "" >> "$sf"
                echo "# Antigravity CLI PATH" >> "$sf"
                echo "$PATH_EXPORT" >> "$sf"
                echo "✓ Updated $sf"
            fi
        fi
    fi
done

export PATH="${LOCAL_BIN}:${PATH}"

# Final Execution Verification
echo ""
echo "Verifying installation with 'agy --version'..."
if "$AGY_LAUNCHER" --version; then
    echo ""
    echo "========================================================="
    echo "  [SUCCESS] Antigravity CLI Installed Successfully!     "
    echo "========================================================="
    echo ""
    echo "Run:"
    echo "    agy"
    echo ""
    echo "To diagnose issues:"
    echo "    agy-doctor"
    echo ""
    exit 0
else
    echo "Fatal Error: Verification 'agy --version' failed." >&2
    exit 1
fi
