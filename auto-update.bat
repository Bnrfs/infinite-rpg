@echo off
chcp 65001 >nul
title 无限流RPG - 自动更新监控

cd /d "%~dp0"

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到Git，请先安装Git
    echo https://git-scm.com/download/win
    pause
    exit /b 1
)

if not exist "index.html" (
    echo [错误] 找不到 index.html 文件
    echo 请确保此脚本与 index.html 在同一目录下
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0auto-update.ps1"

pause