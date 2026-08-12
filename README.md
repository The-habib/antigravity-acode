# Antigravity CLI for Acode Alpine

[![Architecture](https://img.shields.io/badge/Architecture-ARM64-blue.svg)](https://github.com/The-habib/antigravity-acode)
[![Target OS](https://img.shields.io/badge/OS-Alpine%20Linux%20%28Acode%20PRoot%29-green.svg)](https://acode.app)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![CI Status](https://github.com/The-habib/antigravity-acode/actions/workflows/ci.yml/badge.svg)](https://github.com/The-habib/antigravity-acode/actions)

> **A production-quality, open-source installer and user-space compatibility layer enabling Google's official Antigravity CLI (`agy`) to execute natively inside Acode's built-in Alpine Linux terminal on Android ARM64.**

---

## ONE COMMAND INSTALLATION

Open your **Acode Terminal** and run:

```sh
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/install.sh | sh
```

---

## QUICK USAGE

```sh
# Check installed version
agy --version

# List available models (network API check)
agy models

# Start interactive Antigravity CLI
agy

# Run system health diagnostics
agy-doctor

# Update to latest Google release
agy-update

# Uninstall
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/uninstall.sh | sh
```

---

## SYSTEM REQUIREMENTS & TECHNICAL CONSTRAINTS

- **Architecture**: Android `aarch64` / `arm64` (ARM 64-bit device)
- **Environment**: Acode built-in Alpine Linux terminal (`musl` libc)
- **Root Required**: **NO** (Runs 100% in non-root user space)
- **Termux Required**: **NO** (Completely standalone inside Acode)
- **Acode Plugin Required**: **NO** (No plugin or APK modifications)
- **`/sdcard` Execution**: **NO** (Installs to executable `$HOME/.antigravity-acode/`)
- **Network Access**: Required for HTTPS installation, upstream updates, and Google AI API operations

---

## ARCHITECTURE & SECURITY CONTROLS

```
Android OS (ARM64)
  ↓
Acode App Terminal
  ↓
Alpine Linux (musl libc)
  ↓
Isolated Glibc Runtime (~/.antigravity-acode/glibc)
  ↓
Official Google Antigravity CLI binary
  ↓
agy
```

- **Mandatory SHA-512 Verification**: Both the Google release binary tarball and the Debian glibc dynamic runtime package are verified against SHA-512 cryptographic checksums prior to extraction.
- **Strict HTTPS Download Policy**: All external downloads enforce TLS 1.2+ HTTPS (`https://`). Unencrypted HTTP downloads are rejected.
- **Atomic Updates & Fallback**: `update.sh` stages candidate updates, verifies candidate execution via glibc, creates an atomic backup (`antigravity.bak`), and automatically rolls back if verification fails.
- **Zero Token Storage**: Does not intercept, modify, or store authentication tokens. All auth logic is managed natively by Google's official binary at `$HOME/.config/antigravity`.

---

## DOCUMENTATION

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Technical architecture & loader details
- [SECURITY.md](docs/SECURITY.md) — Security controls & cryptographic integrity rules
- [INSTALL.md](docs/INSTALL.md) — Installation instructions
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — Diagnostic fixes & doctor guide

---

## DISCLAIMER & LICENSES

- **Installer & Tooling License**: Open-source under the [MIT License](LICENSE).
- **Google Antigravity CLI**: Proprietary software developed by Google LLC. This repository does NOT contain, distribute, or modify Google's proprietary source code or binaries.

### Official Links
- [Google Antigravity Product Page](https://antigravity.google/product/antigravity-cli)
- [Official Antigravity CLI Installation Documentation](https://antigravity.google/docs/cli/install)
