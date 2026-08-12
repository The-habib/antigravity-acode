# Antigravity for Acode Terminal

[![Architecture](https://img.shields.io/badge/Architecture-ARM64%20%2F%20aarch64-blue.svg)](https://github.com/The-habib/antigravity-acode)
[![Target OS](https://img.shields.io/badge/Target%20OS-Alpine%20Linux%20%28Acode%20PRoot%29-green.svg)](https://acode.app)
[![Developer](https://img.shields.io/badge/Developer-TG%20Habib-orange.svg)](https://github.com/The-habib)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![CI Status](https://github.com/The-habib/antigravity-acode/actions/workflows/ci.yml/badge.svg)](https://github.com/The-habib/antigravity-acode/actions)

> **A standalone, open-source compatibility layer and automated installer enabling Google's official Antigravity CLI (`agy`) to run natively inside Acode's built-in Alpine Linux terminal on supported ARM64 Android devices.**

---

## Overview

**Antigravity for Acode Terminal** (`antigravity-acode`) bridges the compatibility gap between Alpine Linux (`musl` libc) and Google's official Antigravity CLI binary (which targets `glibc` on Linux ARM64).

Created by **[TG Habib](https://github.com/The-habib)**, this project provides a reproducible, zero-root user-space runtime environment. It installs a dedicated, isolated `glibc 2.36` compatibility layer into `$HOME/.antigravity-acode/glibc` without modifying Acode's APK, installing Termux, requiring Android root access, or relying on external Acode plugins.

---

## Key Features

- **Zero-Root & Zero-Plugin**: Runs 100% in user space directly inside Acode's built-in Alpine Linux terminal.
- **Official Google Antigravity CLI**: Invokes the authentic, un-modified upstream Antigravity ARM64 binary (`agy`).
- **Automated Host Self-Bootstrapping**: Automatically audits and installs required Alpine host utilities (`binutils`/`ar`, `xz`, `tar`) via `apk` if missing.
- **Cryptographic Security**: Enforces mandatory SHA-512 checksum verification on all downloaded binaries and packages.
- **Strict HTTPS & TLS 1.2+**: All network requests strictly enforce HTTPS with `--proto '=https' --tlsv1.2`.
- **First-Run Onboarding (`agy-setup`)**: Interactive setup helper that audits runtime health, launches Google authentication, and verifies model access.
- **Health Diagnostics (`agy-doctor`)**: Built-in diagnostic tool to verify ELF headers, glibc loader integrity, PATH setup, and auth state.
- **Upstream Updater (`agy-update`)**: Automated upstream release checker with atomic staging, candidate testing, and automatic rollback on failure.

---

## One-Command Installation

Open your **Acode Terminal** and run:

```sh
apk add curl
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/install.sh | sh
```

> **Note on Prerequisites**: Fresh minimal Alpine Linux terminals require `curl` to fetch the installer. Once `install.sh` starts, it automatically audits and self-bootstraps all remaining required host utilities (such as `binutils`/`ar` and `xz`).

---

## First-Run & Quick Start

### 1. Run First-Time Setup & Authentication (`agy-setup`)
```sh
agy-setup
```
This interactive helper verifies your runtime health, launches legitimate Google OAuth sign-in if unauthenticated, and displays available Google AI models upon success.

### 2. Launch Antigravity CLI (`agy`)
```sh
agy
```

### 3. Check Version & Available Models
```sh
agy --version
agy models
```

### 4. Run System Diagnostics (`agy-doctor`)
```sh
agy-doctor
```

### 5. Update to Latest Upstream Release (`agy-update`)
```sh
agy-update
```

### 6. Uninstall (`uninstall.sh`)
```sh
curl -fsSL https://raw.githubusercontent.com/The-habib/antigravity-acode/main/uninstall.sh | sh
```

---

## How It Works (Architecture)

```
Acode Terminal (Alpine Linux / musl libc / ARM64)
    ↓
`agy` Launcher ($HOME/.local/bin/agy)
    ↓
Isolated glibc Loader ($HOME/.antigravity-acode/glibc/ld-linux-aarch64.so.1)
    ↓
Official Google Antigravity CLI ($HOME/.antigravity-acode/bin/antigravity)
    ↓
Google Gemini / Claude / GPT-OSS Models via TLS API
```

1. **Host Audit & Self-Bootstrapping**: The installer checks for required host tools (`ar`, `xz`, `tar`). If absent on minimal Alpine installations, it automatically installs `binutils` and `xz` via `apk`.
2. **Upstream Release Discovery**: Downloads the official release manifest over HTTPS from Google's auto-updater endpoint and validates SHA-512 hashes.
3. **Isolated Glibc Bridge**: Unpacks Debian `libc6` shared libraries into `$HOME/.antigravity-acode/glibc/` without touching system-level `/lib` or `/usr/lib`.
4. **Transparent Execution**: The `agy` launcher executes `ld-linux-aarch64.so.1 --library-path $HOME/.antigravity-acode/glibc $HOME/.antigravity-acode/bin/antigravity "$@"`, passing arguments seamlessly to the official binary.

---

## Security & Verification

- **Mandatory SHA-512 Verification**: Downloads are verified against 128-hex-character SHA-512 cryptographic hashes before execution.
- **Strict HTTPS Protocol Enforcement**: All downloads explicitly require HTTPS and TLS 1.2+ (`curl --proto '=https' --tlsv1.2`). Unencrypted HTTP fallback is strictly prohibited.
- **Zero-`eval` Shell Execution**: Utility checks and bootstrapping functions use direct POSIX `case` logic without unsafe `eval` calls.
- **Isolated Staging**: Downloads and extractions occur inside private staging directories (`mkdir -m 700`).
- **Fail-Closed Safety**: If any checksum check, binary validation, or management script download fails, installation immediately halts.

---

## System Requirements

- **Device Architecture**: 64-bit ARM (`aarch64` / `arm64`).
- **Application**: [Acode Editor](https://acode.app) with built-in terminal (Alpine Linux environment).
- **Network**: Active internet connection for initial setup and Google AI model communication.

---

## Developer Credit

- **Developer & Maintainer**: **TG Habib** ([@The-habib](https://github.com/The-habib))
- **Repository**: [https://github.com/The-habib/antigravity-acode](https://github.com/The-habib/antigravity-acode)

---

## License & Disclaimer

This project is licensed under the [MIT License](LICENSE).

### Disclaimer & Trademarks
- **Google Antigravity CLI**, **Gemini**, and **Google** are trademarks of Google LLC.
- **antigravity-acode** is an independent, open-source compatibility layer and installer created by **TG Habib**.
- This repository is **not affiliated with, sponsored by, or endorsed by Google LLC**.
