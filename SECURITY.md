# Security Policy

## Reporting Security Issues

If you discover a security vulnerability in **Antigravity for Acode Terminal** (`antigravity-acode`), please report it directly to the developer:

- **Developer**: TG Habib
- **GitHub**: [https://github.com/The-habib](https://github.com/The-habib)
- **Security Contact**: Contact via GitHub issue or private security advisory.

Please do not open public issues for sensitive security vulnerabilities until they have been addressed.

---

## Security Guarantees & Architecture Controls

### 1. Mandatory Cryptographic Checksums
All binary packages downloaded during installation or updates are verified against 128-hexadecimal-character SHA-512 cryptographic hashes. Downloads with missing or mismatched checksums are rejected immediately.

### 2. Strict HTTPS & Minimum TLS 1.2+
All network requests strictly enforce HTTPS with explicit TLS protocol boundaries (`curl --proto '=https' --tlsv1.2`). Unencrypted HTTP fallbacks are prohibited.

### 3. POSIX Execution Safety (Zero-Eval)
All shell scripts (`install.sh`, `update.sh`, `uninstall.sh`, and management tools) use strict POSIX shell constructs (`set -eu`) and avoid dynamic `eval` code execution.

### 4. User-Space Isolation
All glibc libraries and binary files are stored strictly within `$HOME/.antigravity-acode/` and `$HOME/.local/bin/`. No system-level privileges or Android root access are required or requested.
