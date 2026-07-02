<#
.SYNOPSIS
    Installs JASP for SURF Research Cloud Windows workspaces.
.DESCRIPTION
    Downloads the latest JASP MSIX from GitHub and installs silently.
    Always fetches the latest release.
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
$version = $release.tag_name -replace '^v', ''

$url  = "https://github.com/jasp-stats/jasp-desktop/releases/download/$($release.tag_name)/JASP-$version-Windows.msix"
$file = "$env:TEMP\JASP-$version.msix"

Write-Host "Downloading JASP $version..."
Invoke-WebRequest -Uri $url -OutFile $file

Write-Host "Installing..."
Add-AppxPackage -Path $file
Remove-Item $file -Force

Write-Host "JASP $version installed."
exit 0
