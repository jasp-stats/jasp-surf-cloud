<#
.SYNOPSIS
    Installs JASP via direct MSI download for SURF Research Cloud Windows workspaces.
.DESCRIPTION
    Downloads the latest JASP MSI from GitHub releases and installs silently.
    Idempotent — skips if already installed.
#>

$ErrorActionPreference = "Stop"

# Check if JASP is already installed (via registry)
$installed = Get-ItemProperty `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*JASP*" }

if ($installed) {
    Write-Host "JASP is already installed."
    exit 0
}

# Get latest release tag from GitHub API
Write-Host "Fetching latest JASP version..."
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/jasp-stats/jasp-desktop/releases/latest"
$version = $release.tag_name -replace '^v', ''

# Download MSI
$url = "https://github.com/jasp-stats/jasp-desktop/releases/download/$($release.tag_name)/JASP-$version-Windows-Community.msi"
$msi = "$env:TEMP\JASP-$version.msi"

Write-Host "Downloading JASP $version..."
Invoke-WebRequest -Uri $url -OutFile $msi

# Install silently
Write-Host "Installing JASP..."
$process = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /quiet /norestart" -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Error "Installation failed (exit code $($process.ExitCode))"
    exit $process.ExitCode
}

# Clean up
Remove-Item $msi -Force

Write-Host "JASP $version installed."
exit 0
