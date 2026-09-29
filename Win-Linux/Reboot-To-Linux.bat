@echo off
title Chuyen khoi dong sang Linux - NttDz
chcp 65001 >nul
cd /d "%~dp0"

:: Kiem tra va tu dong nang quyen Administrator neu can
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Dang yeu cau quyen Administrator...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: Chay PowerShell script xu ly don dep Windows va chuyen boot sang Linux
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Reboot-To-Linux.ps1" %*
