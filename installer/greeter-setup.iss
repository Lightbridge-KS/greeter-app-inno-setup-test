; ==========================================================================
; GreeterApp Inno Setup Script
;
; Build with:
;   iscc /DAppVersion=1.0.0 /DPublishDir=..\..\publish\win-x64 greeter-setup.iss
;
; Silent install with custom config:
;   GreeterApp-Setup-1.0.0.exe /VERYSILENT /GREETING="Hi" /RECIPIENT="Hospital"
; ==========================================================================

; --- Preprocessor defines (overridable from CLI via /D) ---
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef PublishDir
  #define PublishDir "..\..\publish\win-x64"
#endif

[Setup]
AppId={{8F3A1B2C-4D5E-6F78-9A0B-C1D2E3F4A5B6}
AppName=GreeterApp
AppVersion={#AppVersion}
AppPublisher=Radiology AI Unit
DefaultDirName={autopf}\GreeterApp
DefaultGroupName=GreeterApp
OutputDir=Output
OutputBaseFilename=GreeterApp-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern
UninstallDisplayIcon={app}\GreeterApp.exe

[Files]
; Application files from dotnet publish output
Source: "{#PublishDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

; PowerShell config script (placed alongside the app)
Source: "scripts\Set-AppSettings.ps1"; DestDir: "{app}\scripts"; Flags: ignoreversion

[Icons]
Name: "{group}\GreeterApp"; Filename: "{app}\GreeterApp.exe"
Name: "{group}\Uninstall GreeterApp"; Filename: "{uninstallexe}"

[Run]
; Patch appsettings.json after files are copied
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\Set-AppSettings.ps1"" -ConfigPath ""{app}\appsettings.json"" -Greeting ""{code:GetGreeting}"" -Recipient ""{code:GetRecipient}"" -AppVersion ""{#AppVersion}"""; \
  Flags: runhidden; \
  StatusMsg: "Applying configuration..."

[Code]
// =========================================================================
// Pascal Script: Custom config page + command-line param support
// =========================================================================

var
  ConfigPage: TInputQueryWizardPage;

// --- Helper: read /PARAM="value" from command line, with fallback ---
function GetCommandLineParam(const ParamName, Default: String): String;
var
  I: Integer;
  Param, Prefix: String;
begin
  Result := Default;
  Prefix := '/' + ParamName + '=';
  for I := 1 to ParamCount do
  begin
    Param := ParamStr(I);
    if Pos(Uppercase(Prefix), Uppercase(Param)) = 1 then
    begin
      Result := Copy(Param, Length(Prefix) + 1, MaxInt);
      // Strip surrounding quotes if present
      if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
        Result := Copy(Result, 2, Length(Result) - 2);
      Exit;
    end;
  end;
end;

// --- Create the custom config page ---
procedure InitializeWizard();
begin
  ConfigPage := CreateInputQueryPage(
    wpSelectDir,                         // appears after directory selection
    'Application Settings',              // page title
    'Configure the greeting message.',   // page description
    'Enter the values below. These will be written to appsettings.json.'
  );

  // Add input fields with defaults (or command-line overrides)
  ConfigPage.Add('Greeting:', False);
  ConfigPage.Values[0] := GetCommandLineParam('GREETING', 'Hello');

  ConfigPage.Add('Recipient:', False);
  ConfigPage.Values[1] := GetCommandLineParam('RECIPIENT', 'World');
end;

// --- Expose values to the [Run] section via {code:...} functions ---
function GetGreeting(Param: String): String;
begin
  Result := ConfigPage.Values[0];
end;

function GetRecipient(Param: String): String;
begin
  Result := ConfigPage.Values[1];
end;

// --- Skip the config page during silent install ---
function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  if PageID = ConfigPage.ID then
    Result := WizardSilent();
end;
