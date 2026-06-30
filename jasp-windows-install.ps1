<#
.SYNOPSIS
    Installs JASP via winget for SURF Research Cloud Windows workspaces.
.DESCRIPTION
    Uses Windows Package Manager to install JASP silently.
    Idempotent — skips if already installed.
#>

$ErrorActionPreference = "Stop"

# Check if winget is available
if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found on this system"
    exit 1
}

# Skip if already installed
$installed = winget list --id JASP.JASP --exact 2>$null | Select-String "JASP"
if ($installed) {
    Write-Host "JASP is already installed."
    exit 0
}

# Install silently
Write-Host "Installing JASP..."
winget install `
    --id JASP.JASP `
    --exact `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements

if ($LASTEXITCODE -ne 0) {
    Write-Error "Installation failed (exit code $LASTEXITCODE)"
    exit $LASTEXITCODE
}

Write-Host "JASP installed."
exit 0
