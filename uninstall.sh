#!/bin/sh
# Antigravity CLI for Acode Alpine Linux - Uninstaller
# Usage: uninstall.sh or curl -fsSL .../uninstall.sh | sh

set -u

BASE_DIR="${HOME}/.antigravity-acode"
LOCAL_BIN="${HOME}/.local/bin"

echo "========================================================="
echo "        Antigravity CLI Acode Uninstaller               "
echo "========================================================="
echo ""

echo "Removing installed runtime files..."
rm -rf "$BASE_DIR" 2>/dev/null || true

echo "Removing executable launcher and management tools..."
rm -f "${LOCAL_BIN}/agy" 2>/dev/null || true
rm -f "${LOCAL_BIN}/agy-doctor" 2>/dev/null || true
rm -f "${LOCAL_BIN}/agy-update" 2>/dev/null || true

echo "✓ Uninstallation complete."
echo "Note: User configuration and Google authentication credentials at \$HOME/.config/antigravity were preserved."
