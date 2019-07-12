
@echo off
setlocal enabledelayedexpansion
REM SET DIR=%~dp0%


	set "dSource=E:\Program Files (x86)\Empire Total War - Vanilla - MY MOD TESTING\data\WALI\MACH - Copy.lua"


	set fullpath=!dSource!

	set "PATH=D:\LUA\lua-5.1\bin"

	luac -o "1.luac" "!fullpath!"

	REM python convert_ui.py -x "!fullpath!" "%%~pf%%~nf"
	REM python convert_ui.py -u "!fullpath!" "%%~pf%%~nf.xml"
	ECHO 1.luac


REM set PATH=D:\Python31
REM python convert_ui.py -u popup_battle_results government_screens.xml
REM python convert_ui.py -x popup_battle_results.xml popup_battle_results

pause