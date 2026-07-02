<#
.SYNOPSIS
    Installs JASP for SURF Research Cloud Windows workspaces.
.DESCRIPTION
    Downloads the latest JASP MSI from GitHub and installs silently.
#>

$ErrorActionPreference = "Stop"

$installed = Get-ItemProperty `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*JASP*" }

if ($installed) {
    Write-Host "JASP is already installed."
    exit 0
}

Write-Host "Fetching latest JASP version..."
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/jasp-stats/jasp-desktop/releases/latest"
$msi = $release.assets | Where-Object { $_.name -like "*Windows-Community.msi" }

if (-not $msi) {
    Write-Error "No MSI asset found in latest release"
    exit 1
}

$file = "$env:TEMP\$($msi.name)"
Write-Host "Downloading $($msi.name)..."
Invoke-WebRequest -Uri $msi.browser_download_url -OutFile $file

Write-Host "Installing..."
$proc = Start-Process msiexec.exe -ArgumentList "/i `"$file`" /quiet /norestart" -Wait -PassThru
Remove-Item $file -Force

if ($proc.ExitCode -ne 0) {
    Write-Error "Install failed (exit code $($proc.ExitCode))"
    exit $proc.ExitCode
}

Write-Host "JASP $($release.tag_name) installed."
exit 0
