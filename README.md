# Flutter Setup Tool (Windows)

Two files that make the first Flutter install on Windows survivable:

- **`FlutterSetup-Installer.ps1`** — a PowerShell script that walks through the setup instead of leaving it as a list of manual steps.
- **`flutter-setup-notes.md`** — Arabic technical notes on the parts that actually block beginners: PowerShell `ExecutionPolicy`, permissions, and the misleading errors you meet before a single line of Dart runs.

## Why

The official instructions are correct but assume a working shell. On a fresh Windows machine the first wall is not Flutter — it is PowerShell refusing to run `.ps1` files, with an error that explains nothing. The notes exist so that wall gets named before the user hits it.

## Using it

```powershell
# inspect first, then run
Get-Content .\FlutterSetup-Installer.ps1
powershell -ExecutionPolicy Bypass -File .\FlutterSetup-Installer.ps1
```

`-ExecutionPolicy Bypass` applies to that one process only; it does not permanently weaken the machine policy.

## Status

Draft — written as a reference for students setting up Flutter for the first time, not a packaged installer.
