@echo off
chcp 65001 >nul
title 无限流RPG - 自动更新监控

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到Git！
    pause
    exit /b 1
)

cd /d "d:\trea project\1"
powershell -ExecutionPolicy Bypass -File "auto-update.ps1"

pause