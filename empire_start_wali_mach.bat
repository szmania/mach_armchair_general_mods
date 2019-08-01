@echo Off
setlocal enabledelayedexpansion

echo Backing up scripting.lua files for early, late and native campaigns
copy "%~dp0\data\campaigns\main\scripting.lua.bak" "%~dp0\data\campaigns\main\scripting.lua"
copy "%~dp0\data\campaigns\main_2\scripting.lua.bak" "%~dp0\data\campaigns\main_2\scripting.lua"
copy "%~dp0\data\campaigns\natives\scripting.lua.bak" "%~dp0\data\campaigns\natives\scripting.lua"
copy "%~dp0\data\campaigns\main\scripting.lua" "%~dp0\data\campaigns\main\scripting.lua.bak"
copy "%~dp0\data\campaigns\main_2\scripting.lua" "%~dp0\data\campaigns\main_2\scripting.lua.bak"
copy "%~dp0\data\campaigns\natives\scripting.lua" "%~dp0\data\campaigns\natives\scripting.lua.bak"

echo Adding MACH mod to scripting.lua files for early, late and native campaigns
echo --Starting Machiavelli's Mods >> "%~dp0\data\campaigns\main\scripting.lua"
echo mach = require "WALI/mach" >> "%~dp0\data\campaigns\main\scripting.lua"
echo mach_lib = require "WALI/mach_lib" >> "%~dp0\data\campaigns\main\scripting.lua"
echo mach_lib.update_mach_lua_log("Calling initialize_mach()") >> "%~dp0\data\campaigns\main\scripting.lua"
echo mach.initialize_mach() >> "%~dp0\data\campaigns\main\scripting.lua"

echo --Starting Machiavelli's Mods >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach = require "WALI/mach" >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach_lib = require "WALI/mach_lib" >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach_lib.update_mach_lua_log("Calling initialize_mach()") >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach.initialize_mach() >> "%~dp0\data\campaigns\main_2\scripting.lua"

echo --Starting Machiavelli's Mods >> "%~dp0\data\campaigns\natives\scripting.lua"
echo mach = require "WALI/mach" >> "%~dp0\data\campaigns\natives\scripting.lua"
echo mach_lib = require "WALI/mach_lib" >> "%~dp0\data\campaigns\natives\scripting.lua"
echo mach_lib.update_mach_lua_log("Calling initialize_mach()") >> "%~dp0\data\campaigns\natives\scripting.lua"
echo mach.initialize_mach() >> "%~dp0\data\campaigns\natives\scripting.lua"

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

:STILLRUNNING

cd /d "%~dp0"

ping -n 5 127.0.0.1 > nul

tasklist /FI "IMAGENAME eq Empire.exe" | find /i "Empire.exe"  
IF NOT ERRORLEVEL 1 (GOTO STILLRUNNING) 
IF ERRORLEVEL 1 (GOTO NOTRUNNING)


:NOTRUNNING
echo Empire: Total War is no longer running. Shutting down WALI and cleaning up Machiavelli's Mods

echo Retoring backup scripting.lua files.
del /f "%~dp0\data\campaigns\main\scripting.lua"
rename "%~dp0\data\campaigns\main\scripting.lua.bak" scripting.lua
del /f "%~dp0\data\campaigns\main_2\scripting.lua"
rename "%~dp0\data\campaigns\main_2\scripting.lua.bak" scripting.lua
del /f "%~dp0\data\campaigns\natives\scripting.lua"
rename "%~dp0\data\campaigns\natives\scripting.lua.bak" scripting.lua

echo Killing WALI processes.
TASKKILL /F /IM launch.bat /IM Launcher_ETW.exe /IM "WALI_Engine.exe" /IM "cmd.exe" /IM "WALI_Engine.exe *32"

echo Successfully finished.
pause
exit