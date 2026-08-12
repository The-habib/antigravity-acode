# Antigravity-Acode Security Policy & Specifications

## Security Design Controls

1. **Upstream Cryptographic Integrity Verification**:
   - Downloads official release archives over HTTPS (`tlsv1.2`).
   - Verifies official package SHA-512 checksums before staging or extraction.

2. **Isolated Execution Environment**:
   - Binaries and libraries reside strictly within user-owned home directories (`$HOME/.antigravity-acode` and `$HOME/.local/bin`).
   - Does NOT require `root`, `sudo`, or modifying `/lib`, `/usr/lib`, or system partitions.

3. **No Embedded Proprietary Binaries**:
   - The repository contains ZERO proprietary binaries, zero glibc `.so` files, and zero hardcoded secrets.
   - All runtime components are obtained dynamically from legitimate official distribution mirrors during installation.

4. **Authentication Handling**:
   - Does NOT store, intercept, or exfiltrate Google authentication credentials.
   - Authentication remains 100% managed by Google's official CLI binary stored in `$HOME/.config/antigravity`.
