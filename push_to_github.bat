@echo off
title Push NetAnchor to GitHub
cd /d "%~dp0"
echo ========================================================
echo   Pushing NetAnchor by Madoxs to GitHub (MadOXs12)
echo ========================================================
echo.
git remote remove origin 2>nul
git remote add origin https://github.com/MadOXs12/NetAnchor.git
git branch -M main
git push -u origin main
echo.
if %errorlevel% equ 0 (
    echo [SUCCESS] NetAnchor is live on GitHub!
    echo URL: https://github.com/MadOXs12/NetAnchor
) else (
    echo [NOTICE] If prompted above, log in with your GitHub account.
)
echo.
pause
