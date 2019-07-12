@ECHO OFF
REM luac -o "Replenishment.luac" "Replenishment.lua"
for /r %%i in (*.lua) do IF NOT "%%~xi" == ".luac"  luac -o "%%~ni.luac" "%%~ni.lua" & ^
echo File %%~nxi compiled
pause
