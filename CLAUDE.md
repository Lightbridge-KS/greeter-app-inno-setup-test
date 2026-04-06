# GreeterApp — Inno Setup Test

## Project Overview

**GreeterApp (Inno Setup)** — Minimal .NET 10 CLI app packaged as a Windows `Setup.exe` via Inno Setup 6. Proof-of-concept for Inno Setup-based installer packaging with CI/CD.

## Tech Stack

- .NET 10 (C#, top-level statements)
- Inno Setup 6 (`iscc.exe`, pre-installed on GitHub Actions `windows-latest`)
- GitHub Actions (Windows runner)

## Repo Structure

```
src/GreeterApp/              → .NET CLI app (reads appsettings.json, prints greeting)
installer/greeter-setup.iss  → Inno Setup script (dialog, files, config patching — all-in-one)
installer/scripts/Set-AppSettings.ps1 → Overwrites JSON keys with user values
.github/workflows/build.yml  → CI: publish → iscc → GitHub Release
```

## Build Commands (Windows only)

```bash
# Publish
dotnet publish src/GreeterApp/GreeterApp.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./publish/win-x64

# Build installer (iscc.exe must be on PATH or use full path)
iscc /DAppVersion=1.0.0 /DPublishDir=..\..\publish\win-x64 installer/greeter-setup.iss
```

Output: `installer/Output/GreeterApp-Setup-1.0.0.exe`

## How the Installer Works

1. `.iss` `[Code]` section creates a custom input page (Greeting + Recipient fields) via `CreateInputQueryPage`, inserted after directory selection.
2. `[Files]` copies published app + PowerShell script to install dir.
3. `[Run]` calls `Set-AppSettings.ps1` which reads appsettings.json as JSON, sets the keys, writes it back.
4. Silent install: `Setup.exe /VERYSILENT /GREETING="Hi" /RECIPIENT="Hospital"` — the `[Code]` reads `/PARAM=value` from command line and skips the UI page.

## Key Design Decisions

- `appsettings.json` ships with sensible defaults (not placeholders) — the PowerShell script overwrites values using `ConvertFrom-Json` / `ConvertTo-Json`.
- Single `.iss` file handles everything (dialog, files, post-install action, uninstall).
- `iscc.exe` is pre-installed on `windows-latest` runners — zero CI setup.

## Known Issues / TODOs

- No code-signing configured yet.
- Inno Setup `AppId` GUID should be unique per real product — update before reuse.
