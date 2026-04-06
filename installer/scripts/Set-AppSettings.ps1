<#
.SYNOPSIS
    Writes user-provided values into appsettings.json.

.DESCRIPTION
    Called by Inno Setup [Run] section after file installation.
    Reads the JSON, sets the specified keys, writes it back.
#>
param(
    [Parameter(Mandatory)] [string] $ConfigPath,
    [Parameter(Mandatory)] [string] $Greeting,
    [Parameter(Mandatory)] [string] $Recipient,
    [Parameter(Mandatory)] [string] $AppVersion
)

try {
    $config = Get-Content -Path $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json

    $config.Greeting   = $Greeting
    $config.Recipient  = $Recipient
    $config.AppVersion = $AppVersion

    $config | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -NoNewline -ErrorAction Stop

    Write-Host "appsettings.json updated successfully."
}
catch {
    Write-Error "Failed to update appsettings.json: $_"
    exit 1
}
