# GreeterApp — Inno Setup Installer Example

Minimal .NET 10 CLI app packaged as a Windows `Setup.exe` using Inno Setup 6.

## What It Does

Reads `appsettings.json` and prints a greeting:

```
Hello, Ramathibodi Hospital!
App Version: 1.0.0
Install Path: C:\Program Files\GreeterApp\
```

## Installer Features

- Custom wizard page for **Greeting** and **Recipient** fields
- Values written to `appsettings.json` via PowerShell post-install
- Silent install support:
  ```
  GreeterApp-Setup-1.0.0.exe /VERYSILENT /GREETING="Hi" /RECIPIENT="Hospital"
  ```
- Clean uninstall via Add/Remove Programs

## Local Build

```bash
# 1. Publish the app
dotnet publish src/GreeterApp/GreeterApp.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./publish/win-x64

# 2. Build the installer (Inno Setup 6 must be installed)
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DAppVersion=1.0.0 /DPublishDir=.\publish\win-x64 installer\greeter-setup.iss
```

Output: `installer/Output/GreeterApp-Setup-1.0.0.exe`

## CI/CD

Push a version tag to trigger the GitHub Actions workflow:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Builds the installer and attaches it to a GitHub Release. No extra setup needed — `iscc.exe` is pre-installed on `windows-latest` runners.
