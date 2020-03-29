@echo Off
setlocal enabledelayedexpansion

SET empire_dir=%~dp0

SET log_file_path=!empire_dir!empire_start_wali_mach.log

echo Deleting log file "!log_file_path!" >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" > !log_file_path!

echo Backing up scripting.lua files for early, late and native campaigns >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
copy "%~dp0\data\campaigns\main\scripting.lua.bak" "%~dp0\data\campaigns\main\scripting.lua"
copy "%~dp0\data\campaigns\main_2\scripting.lua.bak" "%~dp0\data\campaigns\main_2\scripting.lua"
copy "%~dp0\data\campaigns\natives\scripting.lua.bak" "%~dp0\data\campaigns\natives\scripting.lua"
copy "%~dp0\data\campaigns\main\scripting.lua" "%~dp0\data\campaigns\main\scripting.lua.bak"
copy "%~dp0\data\campaigns\main_2\scripting.lua" "%~dp0\data\campaigns\main_2\scripting.lua.bak"
copy "%~dp0\data\campaigns\natives\scripting.lua" "%~dp0\data\campaigns\natives\scripting.lua.bak"


echo Adding MACH mod to scripting.lua files for early, late and native campaigns >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
echo --START Machiavelli's Mods > "%~dp0\data\campaigns\main\scripting.lua"
echo mach = require "WALI/mach" >> "%~dp0\data\campaigns\main\scripting.lua"
echo mach_lib = require "WALI/mach_lib" >> "%~dp0\data\campaigns\main\scripting.lua"
echo mach_lib.update_mach_lua_log("Calling initialize_mach()") >> "%~dp0\data\campaigns\main\scripting.lua"
echo mach.initialize_mach() >> "%~dp0\data\campaigns\main\scripting.lua"
echo --END Machiavelli's Mods >> "%~dp0\data\campaigns\main\scripting.lua"
echo.>> "%~dp0\data\campaigns\main\scripting.lua"
type "%~dp0\data\campaigns\main\scripting.lua.bak" >> "%~dp0\data\campaigns\main\scripting.lua"

echo --Starting Machiavelli's Mods > "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach = require "WALI/mach" >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach_lib = require "WALI/mach_lib" >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach_lib.update_mach_lua_log("Calling initialize_mach()") >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo mach.initialize_mach() >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo --END Machiavelli's Mods >> "%~dp0\data\campaigns\main_2\scripting.lua"
echo.>> "%~dp0\data\campaigns\main_2\scripting.lua"
type "%~dp0\data\campaigns\main_2\scripting.lua.bak" >> "%~dp0\data\campaigns\main_2\scripting.lua"

echo --Starting Machiavelli's Mods > "%~dp0\data\campaigns\natives\scripting.lua"
echo mach = require "WALI/mach" >> "%~dp0\data\campaigns\natives\scripting.lua"
echo mach_lib = require "WALI/mach_lib" >> "%~dp0\data\campaigns\natives\scripting.lua"
echo mach_lib.update_mach_lua_log("Calling initialize_mach()") >> "%~dp0\data\campaigns\natives\scripting.lua"
echo mach.initialize_mach() >> "%~dp0\data\campaigns\natives\scripting.lua"
echo --END Machiavelli's Mods >> "%~dp0\data\campaigns\natives\scripting.lua"
echo.>> "%~dp0\data\campaigns\natives\scripting.lua"
type "%~dp0\data\campaigns\natives\scripting.lua.bak" >> "%~dp0\data\campaigns\natives\scripting.lua"

echo Starting WALI >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!

echo Changing directory to ./data/WALI >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
cd /d "%~dp0\data\WALI"

echo Launching WALI >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
start launch.bat 2>&1

echo Changing directory to Empire directory "%~dp0" >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
cd /d "%~dp0"

SET process_name=

if exist Imperial.Splendour.exe (
    echo Starting Imperial Splendour Launcher "Imperial.Splendour.exe" >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
    start Imperial.Splendour.exe > output.log
    SET exe_name=Imperial.Splendour.exe
    SET process_name=javaw.exe
) else (
	echo Starting Empire Total War "Empire.exe" >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
	start Empire.exe > output.log
	SET exe_name=Empire.exe
	SET process_name=Empire.exe
)


echo Checking if "!exe_name!" is still running. If not, kill WALI. >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!

ping -n 5 127.0.0.1 > nul

:STILLRUNNING

cd /d "%~dp0"

ping -n 5 127.0.0.1 > nul

tasklist /FI "IMAGENAME eq !process_name!" | find /i "!process_name!"
IF NOT ERRORLEVEL 1 (GOTO STILLRUNNING) 
IF ERRORLEVEL 1 (GOTO NOTRUNNING)


:NOTRUNNING
echo "!exe_name!" is no longer running. Shutting down WALI and cleaning up Machiavelli's Mods >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!

echo Restoring backup scripting.lua files. >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
del /f "%~dp0\data\campaigns\main\scripting.lua"
rename "%~dp0\data\campaigns\main\scripting.lua.bak" scripting.lua
del /f "%~dp0\data\campaigns\main_2\scripting.lua"
rename "%~dp0\data\campaigns\main_2\scripting.lua.bak" scripting.lua
del /f "%~dp0\data\campaigns\natives\scripting.lua"
rename "%~dp0\data\campaigns\natives\scripting.lua.bak" scripting.lua

echo Killing WALI processes. >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
TASKKILL /F /IM launch.bat /IM Launcher_ETW.exe /IM "WALI_Engine.exe" /IM "WALI_Engine.exe *32"

echo Successfully finished. >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!

echo Deleting file "!empire_dir!_" >"!empire_dir!_" && type "!empire_dir!_" && type "!empire_dir!_" >> !log_file_path!
del "!empire_dir!_"

TASKKILL /F /IM "cmd.exe"
pause
exit