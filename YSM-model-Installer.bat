@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
cls

echo ============================================
echo       YSM 免费模型 - 终极安装器
echo ============================================
echo.

REM ============================================
REM 智能检测 Minecraft 目录
REM ============================================
set "REPO_DIR=%~dp0"
set "MC_ROOT="

REM 方法1：检测仓库父目录
for %%i in ("%REPO_DIR%..") do set "PARENT_DIR=%%~fi"
if exist "%PARENT_DIR%\.minecraft" (
    set "MC_ROOT=%PARENT_DIR%\.minecraft"
    goto :found_mc
)

REM 方法2：检测仓库同级目录
if exist "%REPO_DIR%.minecraft" (
    set "MC_ROOT=%REPO_DIR%.minecraft"
    goto :found_mc
)

REM 方法3：检测常见的 PCL2 目录结构
if exist "D:\PCL2\.minecraft" (
    set "MC_ROOT=D:\PCL2\.minecraft"
    goto :found_mc
)

REM 方法4：检测当前盘符的 PCL2 目录
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\PCL2\.minecraft" (
        set "MC_ROOT=%%d:\PCL2\.minecraft"
        goto :found_mc
    )
)

REM 方法5：手动输入
echo 未自动找到 .minecraft 目录
echo 请手动输入 .minecraft 路径（例如：D:\PCL2\.minecraft）
set /p MC_ROOT=请输入路径：
if not exist "!MC_ROOT!" (
    echo 路径无效，脚本退出
    pause
    exit /b 1
)

:found_mc
REM 规范化路径（去掉 ..）
for %%i in ("!MC_ROOT!") do set "MC_ROOT=%%~fi"
echo 检测到 Minecraft 目录：!MC_ROOT!

set "SELF_NAME=%~nx0"
set "EXCLUDE_DIRS=.git .github tools docs"

REM --- 初始化统计 ---
set /a TOTAL_YSM=0
set /a TOTAL_ZIP=0
set /a TOTAL_7Z=0
set /a TOTAL_AUTHORS=0

REM ============================================
REM   Step 1: 汇总所有作者的 Readme
REM ============================================
echo [1/4] 正在汇总作者说明...
set "README_LIST=%REPO_DIR%readme_list.txt"

> "%README_LIST%" echo ============================================
>>"%README_LIST%" echo           YSM 模型作者说明汇总
>>"%README_LIST%" echo ============================================
>>"%README_LIST%" echo 生成时间：%date% %time%
>>"%README_LIST%" echo 仓库位置：%REPO_DIR%
>>"%README_LIST%" echo Minecraft：!MC_ROOT!
>>"%README_LIST%" echo.

for /d %%D in ("%REPO_DIR%\*") do (
    set "FolderName=%%~nxD"
    echo !EXCLUDE_DIRS! | findstr /i "%%~nxD" >nul || (
        if exist "%%D\readme.txt" (
            >> "%README_LIST%" echo ================ [%%~nxD] ================
            >> "%README_LIST%" type "%%D\readme.txt"
            >> "%README_LIST%" echo.
            >> "%README_LIST%" echo.
        )
    )
)
echo 已生成：readme_list.txt

REM ============================================
REM   Step 2: 统计模型文件
REM ============================================
echo.
echo [2/4] 统计模型文件...

for /d %%D in ("%REPO_DIR%\*") do (
    set "FolderName=%%~nxD"
    echo !EXCLUDE_DIRS! | findstr /i "%%~nxD" >nul || (
        REM 使用 dir 命令统计文件数量
        for /f %%i in ('dir /b /s "%%D\*.ysm" 2^>nul ^| find /c /v ""') do set /a TOTAL_YSM+=%%i
        for /f %%i in ('dir /b /s "%%D\*.zip" 2^>nul ^| find /c /v ""') do set /a TOTAL_ZIP+=%%i
        for /f %%i in ('dir /b /s "%%D\*.7z" 2^>nul ^| find /c /v ""') do set /a TOTAL_7Z+=%%i
        
        REM 检查是否有模型文件
        dir /b /s "%%D\*.ysm" "%%D\*.zip" "%%D\*.7z" >nul 2>&1
        if not errorlevel 1 (
            set /a TOTAL_AUTHORS+=1
        )
    )
)

set /a TOTAL_MODELS=TOTAL_YSM+TOTAL_ZIP+TOTAL_7Z
echo 发现 !TOTAL_AUTHORS! 位作者，共 !TOTAL_MODELS! 个模型文件。

REM ============================================
REM   Step 3: 安装模型到 Minecraft
REM ============================================
echo.
echo [3/4] 开始安装模型...

for /d %%V in ("!MC_ROOT!\versions\*") do (
    set "TARGET=%%V\config\yes_steve_model\custom"
    
    if exist "%%V" (
        echo   正在处理版本：%%~nxV
        
        REM 检测 YSM 模组
        dir /b "%%V\mods\*ysm*.jar" >nul 2>&1
        if errorlevel 1 (
            echo     警告：未检测到 YSM 模组，跳过安装。
            echo     请确保 mods 文件夹内有类似 ysm-x.x.x-forge-mc1.20.1-all.jar
        ) else (
            echo     检测到 YSM 模组，开始安装...
            
            if not exist "!TARGET!" mkdir "!TARGET!"
            
            for /d %%D in ("%REPO_DIR%\*") do (
                set "FolderName=%%~nxD"
                echo !EXCLUDE_DIRS! | findstr /i "%%~nxD" >nul || if /i not "%%~nxD"=="!SELF_NAME!" (
                    
                    dir /b /s "%%D\*.ysm" "%%D\*.zip" "%%D\*.7z" >nul 2>&1
                    if not errorlevel 1 (
                        echo       复制：%%~nxD
                        robocopy "%%D" "!TARGET!\%%~nxD" *.ysm *.zip *.7z /E /R:1 /W:1 /NFL /NDL /NJH /NJS >nul
                    )
                )
            )
        )
    )
)

REM ============================================
REM   Step 4: 生成统计报告
REM ============================================
echo.
echo [4/4] 生成统计报告...

set "REPORT_FILE=%REPO_DIR%install_report.txt"
> "%REPORT_FILE%" echo ============================================
>>"%REPORT_FILE%" echo          YSM 模型安装报告
>>"%REPORT_FILE%" echo ============================================
>>"%REPORT_FILE%" echo 安装时间：%date% %time%
>>"%REPORT_FILE%" echo 仓库位置：%REPO_DIR%
>>"%REPORT_FILE%" echo Minecraft：!MC_ROOT!
>>"%REPORT_FILE%" echo.
>>"%REPORT_FILE%" echo 已覆盖版本数：
for /d %%V in ("!MC_ROOT!\versions\*") do (
    >>"%REPORT_FILE%" echo    - %%~nxV
)
>>"%REPORT_FILE%" echo.
>>"%REPORT_FILE%" echo 作者包数量：!TOTAL_AUTHORS!
>>"%REPORT_FILE%" echo 模型文件总数：!TOTAL_MODELS!
>>"%REPORT_FILE%" echo    - YSM 文件：!TOTAL_YSM!
>>"%REPORT_FILE%" echo    - ZIP 文件：!TOTAL_ZIP!
>>"%REPORT_FILE%" echo    - 7Z 文件：!TOTAL_7Z!
>>"%REPORT_FILE%" echo.
>>"%REPORT_FILE%" echo ============================================
>>"%REPORT_FILE%" echo 请查看 readme_list.txt 了解作者详情。
>>"%REPORT_FILE%" echo ============================================

type "%REPORT_FILE%"
echo.
echo 已生成：install_report.txt

REM ============================================
REM   完成
REM ============================================
echo.
echo ============================================
echo   所有操作已完成！
echo   -模型已安装至各版本配置文件夹
echo   -作者说明已汇总至 readme_list.txt
echo   -统计报告已生成
echo ============================================
echo.
echo 按任意键打开模型文件夹，查看安装情况...
pause >nul

REM 打开第一个版本的 custom 文件夹
for /d %%V in ("!MC_ROOT!\versions\*") do (
    if exist "%%V\config\yes_steve_model\custom" (
        start "" "%%V\config\yes_steve_model\custom"
        goto :end
    )
)

:end
pause