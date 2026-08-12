# Troubleshooting Guide

## `sh: agy: not found`
If `agy` is not recognized immediately after installation:
1. Ensure `$HOME/.local/bin` is in your PATH:
   ```sh
   export PATH="$HOME/.local/bin:$PATH"
   ```
2. Or open a new terminal session in Acode.

## Run Diagnostics
Run the diagnostic command at any time:
```sh
agy-doctor
```

It will test architecture, loader, binary, PATH, and connectivity.
