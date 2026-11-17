<#
.SYNOPSIS
    NetAnchor / Quick Setup Machine Installer - Creates Desktop & Start Menu Shortcuts
    Author: MadOxs (@MadOXs12)
#>

param()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcherBat = Join-Path $scriptDir "Quick Setup Machine.bat"
if (-not (Test-Path $launcherBat)) {
    $launcherBat = Join-Path $scriptDir "NetAnchor.bat"
}

if (-not (Test-Path $launcherBat)) {
    Write-Error "Launcher file not found in: $scriptDir"
    exit 1
}

$wshShell = New-Object -ComObject WScript.Shell

# 1. Desktop Shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$desktopLnk = Join-Path $desktopPath "Quick Setup Machine.lnk"
$shortcut = $wshShell.CreateShortcut($desktopLnk)
$shortcut.TargetPath = $launcherBat
$shortcut.WorkingDirectory = $scriptDir
$shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,238" # Shield / Security icon
$shortcut.Description = "Quick Setup Machine (NetAnchor) - Zero-Drop Network & Gaming Optimizer"
$shortcut.Save()

# 2. Start Menu Shortcut
$startMenuPath = [Environment]::GetFolderPath("Programs")
$startMenuLnk = Join-Path $startMenuPath "Quick Setup Machine.lnk"
$shortcut2 = $wshShell.CreateShortcut($startMenuLnk)
$shortcut2.TargetPath = $launcherBat
$shortcut2.WorkingDirectory = $scriptDir
$shortcut2.IconLocation = "$env:SystemRoot\System32\shell32.dll,238"
$shortcut2.Description = "Quick Setup Machine (NetAnchor) - Zero-Drop Network & Gaming Optimizer"
$shortcut2.Save()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Quick Setup Machine (NetAnchor) Installed Successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  [+] Desktop Shortcut:    $desktopLnk" -ForegroundColor White
Write-Host "  [+] Start Menu Shortcut: $startMenuLnk" -ForegroundColor White
Write-Host ""
Write-Host "You can now run Quick Setup Machine directly from your Desktop!" -ForegroundColor Yellow
