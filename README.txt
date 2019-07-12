Originally created by .Mitch and TC.

Engine:		Contains engine source files
Interface:	Directory used for WALI -> Lua and Lua -> WALI communication
Logs:		Directory used to output logs, from both WALI and Lua. 
Misc:		Misc files, should be kept as they are reference in code comments (as "for example see ...")
UI_final:	Final version of all UI files in use
UI_wips:	Contains any WIP UI files. Also contains UI compilers/decompilers and a Lua compiler compatible with ETW/NTW

Launcher_ETW.exe:	Engine launcher, WALI can only start through this
WALI.lua:			WALI lua function library, contains all of WALI's Lua side functionality. To run WALI from lua 
					(and attrition functionality) :
					WALI = require "WALI/WALI"
					WALI.InitialiseAttrition()
WALI.pack:			Contains a packed version of the UI files, needed for the scripting to run. Format shouldn't matter,
					is currently in mod format

More Details: http://www.twcenter.net/forums/showthread.php?604949-W-A-L-I

Spacial thanks to VadAntS for inspiration.
