@echo off
chcp 65001 >nul
echo ======================================
echo   无限流RPG - 一键更新部署
echo   网址: https://bnrfs.github.io/infinite-rpg/
echo ======================================
echo.

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到Git，请先安装Git
    pause
    exit /b 1
)

set /p commit_msg="更新说明 (直接回车跳过): "
if "%commit_msg%"=="" set commit_msg=更新游戏内容

echo.
echo [1/3] 添加文件...
git add index.html

echo [2/3] 提交更改...
git commit -m "%commit_msg%"

echo [3/3] 推送到GitHub...
git push

if %errorlevel% equ 0 (
    echo.
    echo ======================================
    echo   ✅ 更新成功！1-2分钟后刷新页面即可
    echo   📱 https://bnrfs.github.io/infinite-rpg/
    echo ======================================
) else (
    echo.
    echo [错误] 推送失败，请检查网络连接
)

pause