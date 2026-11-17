<#
.SYNOPSIS
    NetAnchor Installer - Creates Desktop & Start Menu Shortcuts
#>

param()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcherBat = Join-Path $scriptDir "NetAnchor.bat"

if (-not (Test-Path $launcherBat)) {
    Write-Error "Launcher file not found at: $launcherBat"
    exit 1
}

$wshShell = New-Object -ComObject WScript.Shell

# 1. Desktop Shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$desktopLnk = Join-Path $desktopPath "NetAnchor.lnk"
$shortcut = $wshShell.CreateShortcut($desktopLnk)
$shortcut.TargetPath = $launcherBat
$shortcut.WorkingDirectory = $scriptDir
$shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,238" # Shield / Security icon
$shortcut.Description = "NetAnchor Pro - Zero-Drop Network & Gaming Optimizer"
$shortcut.Save()

# 2. Start Menu Shortcut
$startMenuPath = [Environment]::GetFolderPath("Programs")
$startMenuLnk = Join-Path $startMenuPath "NetAnchor.lnk"
$shortcut2 = $wshShell.CreateShortcut($startMenuLnk)
$shortcut2.TargetPath = $launcherBat
$shortcut2.WorkingDirectory = $scriptDir
$shortcut2.IconLocation = "$env:SystemRoot\System32\shell32.dll,238"
$shortcut2.Description = "NetAnchor Pro - Zero-Drop Network & Gaming Optimizer"
$shortcut2.Save()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  NetAnchor Installed Successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  [+] Desktop Shortcut:    $desktopLnk" -ForegroundColor White
Write-Host "  [+] Start Menu Shortcut: $startMenuLnk" -ForegroundColor White
Write-Host ""
Write-Host "You can now run NetAnchor directly from your Desktop!" -ForegroundColor Yellow
