@echo Off
setlocal enabledelayedexpansion
echo Starting WALI

echo Changing directory to ./data/WALI
cd /d "%~dp0\data\WALI"

echo Launching WALI
start launch.bat 2>&1

echo Changing directory to previous directory
cd /d "%~dp0"


echo Starting Empire Total War
start Empire.exe > output.log


echo Checking if Empire Total War is still running. If not, kill WALI.

ping -n 8 127.0.0.1 > nul

:TEST2

cd /d "%~dp0"

ping -n 5 127.0.0.1 > nul

tasklist /FI "IMAGENAME eq Empire.exe" | find /i "Empire.exe"  
IF NOT ERRORLEVEL 1 (GOTO TEST2) 
IF ERRORLEVEL 1 (GOTO TEST1)


:TEST1

TASKKILL /F /IM launch.bat /IM Launcher_ETW.exe /IM "WALI_Engine.exe" /IM "cmd.exe" /IM "WALI_Engine.exe *32"

exit