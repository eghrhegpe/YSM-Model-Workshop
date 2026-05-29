@echo off
chcp 65001 >nul
set OUT=YSM_ZIP_7Z_List.txt

> "%OUT%" echo ===== YSM / ZIP / 7Z 文件清单 =====

for /r %%i in (*.ysm *.zip *.7z) do (
    echo %%~nxi >> "%OUT%"
)

echo 已完成！共提取了以下文件：
type "%OUT%"
pause