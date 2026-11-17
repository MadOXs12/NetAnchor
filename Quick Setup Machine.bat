@echo off
title Quick Setup Machine (NetAnchor) - Zero-Drop Network & Gaming Optimizer
setlocal EnableDelayedExpansion

:: -------------------------------------------------------------------------
:: Quick Setup Machine (NetAnchor Pro) - 1-Click Launcher
:: Developed by MadOxs (@MadOXs12)
:: Official Video: https://youtu.be/G5gHMS4QNto
:: -------------------------------------------------------------------------

:: Check Administrator permissions
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Quick Setup Machine] Requesting Administrator Privileges...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\" %*\"' -Verb RunAs"
    exit /b
)

:: Get directory of this script
set "SCRIPT_DIR=%~dp0"
set "CORE_SCRIPT=%SCRIPT_DIR%src\NetAnchor.ps1"

if not exist "%CORE_SCRIPT%" (
    echo [ERROR] Could not find core script at: "%CORE_SCRIPT%"
    echo Please ensure the "src" folder exists alongside this file.
    pause
    exit /b 1
)

:: Run Engine
powershell -NoProfile -ExecutionPolicy Bypass -File "%CORE_SCRIPT%" %*

exit /b %errorlevel%
