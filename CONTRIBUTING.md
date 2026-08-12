# Contributing Guidelines

Thank you for your interest in contributing to **Antigravity for Acode Terminal** (`antigravity-acode`)!

---

## Development & Test Workflow

### 1. Prerequisites
- POSIX-compliant shell (`sh` / `dash` / `ash`).
- Alpine Linux or Linux ARM64 environment.
- Standard tools: `curl`, `tar`, `xz`, `sha512sum`.

### 2. POSIX Syntax Validation
Before submitting changes, verify that all shell scripts pass strict syntax checks:
```sh
sh -n install.sh
sh -n update.sh
sh -n uninstall.sh
sh -n bin/agy-doctor
sh -n bin/agy-update
sh -n bin/agy-setup
```

### 3. Executing the Test Suite
Run the master test runner to execute unit, security, and launcher tests:
```sh
chmod +x tests/*.sh bin/* install.sh update.sh uninstall.sh
./tests/run_tests.sh
```

---

## Coding Standards

- **Strict POSIX Compatibility**: All scripts must run cleanly in `/bin/sh` on Alpine Linux (`musl` libc). Avoid bash-isms (`[[ ... ]]`, `function`, `<<<`).
- **Zero-Eval Safety**: Do not use `eval` for dynamic code execution or variable evaluations.
- **Strict Network Security**: Enforce HTTPS and TLS 1.2+ (`curl --proto '=https' --tlsv1.2`).
- **Mandatory Verification**: Every download must be non-empty and cryptographically verified.
