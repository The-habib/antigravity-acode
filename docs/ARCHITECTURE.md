# Antigravity CLI for Acode Alpine - Architecture Specification

## Architectural Overview

This project provides an open-source installer and user-space compatibility layer that allows Google's official Antigravity CLI (`agy`) to run natively inside Acode's Alpine Linux terminal on ARM64 Android devices.

```
Android OS (ARM64 Kernel 5.15+)
   │
   └── Acode Application
         │
         └── Built-in Terminal (Alpine Linux / musl libc in PRoot)
               │
               ├── ~/.local/bin/agy (Native Shell Launcher)
               │     │
               │     ├── Detects PRoot & DNS fallback
               │     └── Invokes Explicit Loader
               │
               ├── ~/.antigravity-acode/glibc/ld-linux-aarch64.so.1 (ELF Loader)
               │     └── Loads Glibc Shared Libraries (libc.so.6, libm.so.6, etc.)
               │
               └── ~/.antigravity-acode/bin/antigravity (Official Google AGY Binary)
                     └── Connects to Google Cloud API & Executes Agent Logic
```

## Key Technical Decisions

1. **Official Unmodified Binary**: Uses the legitimate official Linux ARM64 binary published by Google (`cli_linux_arm64.tar.gz`).
2. **Dynamic Upstream Discovery**: Discovers versions and SHA-512 hashes dynamically from Google's release API rather than hard-coding static versions.
3. **Isolated User-Space Glibc**: Installs a minimal 2.3 MB core glibc runtime into `$HOME/.antigravity-acode/glibc/` without requiring root or altering system Alpine files.
4. **Syscall Trap Prevention**: PRoot intercepts Go BoringCrypto initialization syscalls in userspace, avoiding Android 13 kernel `untrusted_app` `seccomp` SIGSYS filters.
