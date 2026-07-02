<#
.SYNOPSIS
    Installs JASP for SURF Research Cloud Windows workspaces.
.DESCRIPTION
    Downloads the latest JASP MSIX from GitHub and installs silently.
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
$msix = $release.assets | Where-Object { $_.name -like "*Windows.msix" }

if (-not $msix) {
    Write-Error "No MSIX asset found in latest release"
    exit 1
}

$file = "$env:TEMP\$($msix.name)"
Write-Host "Downloading $($msix.name)..."
Invoke-WebRequest -Uri $msix.browser_download_url -OutFile $file

Write-Host "Installing..."
Add-AppxPackage -Path $file
Remove-Item $file -Force

Write-Host "JASP $($release.tag_name) installed."
exit 0
