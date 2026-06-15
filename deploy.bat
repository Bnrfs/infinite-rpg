@echo off
chcp 65001 >nul
echo ======================================
echo   无限流RPG - 一键部署脚本
echo ======================================
echo.

REM 检查git是否安装
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到Git，请先安装Git：
    echo https://git-scm.com/download/win
    pause
    exit /b 1
)

REM 检查是否已初始化git仓库
if not exist ".git" (
    echo [信息] 首次使用，正在初始化Git仓库...
    git init
    echo.
    echo 请输入你的GitHub仓库地址（例如：https://github.com/用户名/infinite-rpg.git）：
    set /p repo_url="仓库地址: "
    git remote add origin !repo_url!
    echo [完成] 仓库已关联
    echo.
)

REM 获取提交信息
set /p commit_msg="请输入更新说明（直接回车使用默认说明）: "
if "%commit_msg%"=="" set commit_msg=更新游戏内容

echo.
echo [步骤1/3] 添加文件到暂存区...
git add .

echo [步骤2/3] 提交更改...
git commit -m "%commit_msg%"

echo [步骤3/3] 推送到GitHub...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ======================================
    echo   ✅ 部署成功！
    echo   等待1-3分钟后刷新页面即可看到更新
    echo ======================================
) else (
    echo.
    echo [错误] 推送失败，请检查：
    echo   1. 网络连接是否正常
    echo   2. GitHub仓库地址是否正确
    echo   3. 是否有推送权限
)

pause