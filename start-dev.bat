@echo off
echo ======================================
echo   无限流RPG - 开发服务器
echo   修改文件后浏览器自动刷新
echo ======================================
echo.
echo 选择启动方式:
echo [1] Node.js 服务器 (推荐, 自动刷新)
echo [2] Python 服务器 (需安装Python)
echo.
set /p choice="请输入选项 (1/2): "

if "%choice%"=="1" (
    echo 正在启动 Node.js 服务器...
    node server.js
    pause
) else if "%choice%"=="2" (
    echo 正在启动 Python 服务器...
    echo 提示: 修改文件后需手动刷新浏览器
    python -m http.server 3000
    pause
) else (
    echo 无效选项
    pause
)