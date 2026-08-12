# Antigravity CLI for Acode Alpine

[![Architecture](https://img.shields.io/badge/Architecture-ARM64-blue.svg)](https://github.com/The-habib/antigravity-acode)
[![Target OS](https://img.shields.io/badge/OS-Alpine%20Linux%20%28Acode%20PRoot%29-green.svg)](https://acode.app)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![CI Status](https://github.com/The-habib/antigravity-acode/actions/workflows/ci.yml/badge.svg)](https://github.com/The-habib/antigravity-acode/actions)

> **A production-quality open-source installer and user-space compatibility layer that enables Google's official Antigravity CLI (`agy`) to execute natively inside Acode's built-in Alpine Linux terminal on Android ARM64.**

---

## Why This Compatibility Layer Is Needed

Acode's built-in terminal runs **Alpine Linux** (`musl` libc). Upstream Google Antigravity CLI binaries for Linux ARM64 are dynamically linked executables built against `glibc` (`/lib/ld-linux-aarch64.so.1`). Attempting to execute the binary directly in Alpine results in `sh: agy: not found`.

`antigravity-acode` solves this problem by providing an **isolated user-space glibc runtime** directly in `$HOME/.antigravity-acode/glibc/`. It requires **zero root**, **zero Termux**, **zero Acode plugins**, and **zero system modification**.

```
Android OS (ARM64)
  ↓
Acode App Terminal
  ↓
Alpine Linux (musl)
  ↓
glibc compatibility runtime (~/.antigravity-acode/glibc)
  ↓
official Google Antigravity CLI binary
  ↓
agy
```

---

## One-Command Installation

Open your **Acode Terminal** and run:

```sh
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/install.sh | sh
```

Once completed, open any new Acode terminal or run:

```sh
agy --version
```

---

## Quick Usage

### Start Antigravity CLI
```sh
agy
```

### Check Version
```sh
agy --version
```

### Run Health Diagnostics
```sh
agy-doctor
```

### Update to Latest Upstream Release
```sh
agy-update
```

### Uninstall
```sh
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/uninstall.sh | sh
```

---

## Technical Highlights

- **Real Official Binary**: Fetches and executes Google's official unmodified release binary directly from Google's release servers.
- **Dynamic Release Discovery**: Automatically discovers release versions and verifies package SHA-512 checksums without hardcoded version strings.
- **Isolated User-Space Runtime**: Ships a minimal 2.3 MB core glibc library bundle in `$HOME/.antigravity-acode/glibc/` without touching system `/lib` files or needing root access.
- **Atomic Upgrades & Rollback**: `update.sh` verifies candidate binaries before replacing existing working binaries, automatically rolling back if verification fails.
- **Zero Account Token Interception**: Authentication remains 100% managed by Google's official CLI.

---

## Documentation

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Detailed technical architecture and PRoot execution mechanics
- [SECURITY.md](docs/SECURITY.md) — Security controls, SHA-512 verification, and non-root execution policy
- [INSTALL.md](docs/INSTALL.md) — Extended installation instructions
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — Common diagnostic fixes and error explanations

---

## Disclaimer & Licenses

- **Installer License**: The installer and wrapper scripts in this repository are open-source under the [MIT License](LICENSE).
- **Google Antigravity CLI**: Google Antigravity CLI is proprietary software developed by Google LLC. This repository does NOT contain, distribute, or modify Google's proprietary source code or binaries.

### Official Links
- [Google Antigravity Product Page](https://antigravity.google/product/antigravity-cli)
- [Official Antigravity CLI Installation Documentation](https://antigravity.google/docs/cli/install)
