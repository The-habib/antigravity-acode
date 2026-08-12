# Antigravity CLI for Acode Alpine

[![Architecture](https://img.shields.io/badge/Architecture-ARM64-blue.svg)](https://github.com/The-habib/antigravity-acode)
[![Target OS](https://img.shields.io/badge/OS-Alpine%20Linux%20%28Acode%20PRoot%29-green.svg)](https://acode.app)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![CI Status](https://github.com/The-habib/antigravity-acode/actions/workflows/ci.yml/badge.svg)](https://github.com/The-habib/antigravity-acode/actions)

> **A production-quality open-source installer and isolated compatibility layer enabling Google's official Antigravity CLI (`agy`) to run natively inside Acode's built-in Alpine Linux terminal on Android ARM64.**

---

## ONE-COMMAND INSTALLATION

Open your **Acode Terminal** and run:

```sh
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/install.sh | sh
```

---

## FIRST-RUN & USAGE GUIDE

### 1. First-Run Setup (`agy-setup`)
Run the interactive setup helper to verify runtime health and launch Google authentication:
```sh
agy-setup
```

### 2. Launch Antigravity CLI (`agy`)
```sh
agy
```

### 3. Check Version & Models
```sh
agy --version
agy models
```

### 4. Health Diagnostics (`agy-doctor`)
```sh
agy-doctor
```

### 5. Update to Latest Upstream Release (`agy-update`)
```sh
agy-update
```

### 6. Uninstall
```sh
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/uninstall.sh | sh
```

---

## PATH UX & CURRENT SHELL SESSION

Child processes (like `install.sh`) cannot modify their parent shell's active environment variables.
The installer configures persistent PATH in `~/.profile` and `~/.ashrc` for future terminal windows.

To use `agy` immediately in your **current** terminal session:
```sh
export PATH="$HOME/.local/bin:$PATH"
```

---

## GOOGLE AUTHENTICATION INFORMATION

- Google's official Antigravity CLI requires interactive OAuth authentication with a Google account.
- **`antigravity-acode` NEVER bypasses, stores, or automates authentication.**
- Running `agy` or `agy-setup` presents Google's official sign-in link.
- Credentials remain managed 100% natively by Google's official binary inside `$HOME/.config/antigravity`.

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

## SECURITY & ARCHITECTURE CONTROLS

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

- **Mandatory Cryptographic Verification**: Google's binary tarball and Debian's core glibc package are verified against SHA-512 checksums prior to extraction.
- **Strict HTTPS Download Policy**: All external downloads enforce TLS 1.2+ HTTPS (`https://`). Unencrypted HTTP downloads are rejected.
- **Staging & Safe Rollback**: `update.sh` stages candidate binaries in private `700` directories, tests candidate execution via glibc, creates atomic backups (`antigravity.bak`), and automatically rolls back if validation fails.

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
