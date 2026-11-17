@echo off
title NetAnchor Pro - Zero-Drop Network & Gaming Optimizer
setlocal EnableDelayedExpansion

:: -------------------------------------------------------------------------
:: NetAnchor Root Launcher
:: Automatically requests Administrator elevation and boots the engine
:: -------------------------------------------------------------------------

:: Check Administrator permissions
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [NetAnchor] Requesting Administrator Privileges...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\" %*\"' -Verb RunAs"
    exit /b
)

:: Get directory of this script
set "SCRIPT_DIR=%~dp0"
set "CORE_SCRIPT=%SCRIPT_DIR%src\NetAnchor.ps1"

if not exist "%CORE_SCRIPT%" (
    echo [ERROR] Could not find core script at: "%CORE_SCRIPT%"
    pause
    exit /b 1
)

:: Run NetAnchor PowerShell Engine
powershell -NoProfile -ExecutionPolicy Bypass -File "%CORE_SCRIPT%" %*

exit /b %errorlevel%
