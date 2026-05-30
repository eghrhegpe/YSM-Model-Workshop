@echo off
chcp 65001 >nul
cls

echo ============================================
echo       调试模式 - YSM 安装器
echo ============================================
echo.

REM 设置日志文件
set "LOG_FILE=%~dp0install_debug.log"

echo 开始时间：%date% %time% > "%LOG_FILE%"
echo 脚本路径：%~f0 >> "%LOG_FILE%"
echo 当前目录：%CD% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM 运行主安装脚本并记录所有输出
echo 正在运行 YSM-model-Installer.bat...
echo 日志将保存到：%LOG_FILE%
echo.

REM 方法1：使用 call 命令运行另一个 bat 文件
call "%~dp0YSM-model-Installer.bat" >> "%LOG_FILE%" 2>&1

REM 方法2：或者直接运行（如果上面不行就用这个）
REM "%~dp0YSM-model-Installer.bat" >> "%LOG_FILE%" 2>&1

echo. >> "%LOG_FILE%"
echo 结束时间：%date% %time% >> "%LOG_FILE%"

echo.
echo ============================================
echo 调试完成！正在打开日志文件...
echo ============================================
pause

REM 打开日志文件
start notepad "%LOG_FILE%"