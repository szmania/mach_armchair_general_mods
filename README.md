# Machiavelli's Armchair General Mods for Empire: Total War
Machiavelli's Armchair General Mods collection for Empire: Total War.

This Mod collection uses WALI "Warscape Added Lua Interface" [WALI FOUND HERE](http://www.twcenter.net/forums/showthread.php?604949-W-A-L-I) which was originally created by .Mitch and TC of the TWCenter Community.

This Mod was also inspired by the work of VadAntS of the TWCenter Community.

## What this Mod adds to Empire: Total War
This Mod is intended to be a collection of mods to enhance Empire: Total War.

Mods within the collection are:
1. Machiavelli's Battle Chronicler

### Machiavelli's Battle Chronicler
This Mod adds a battle chronicler to Empire: Total War. This is a mechanism that describes and keeps track of ALL battles fought within Empire: Total War (both Player and AI battles). 

**Features**

* Battle events are presented to the player via messages (AI battles) and a history of all battles (both AI and Player battles) is maintained.
* Every character maintains a history of all the battles it has participated in.
    (can be viewed by hovering the mouse over the character portrait in character details window)
* Every unit maintains a history of all the battles it has participated in.
    (can be viewed by opening unit details window and reading the top portion of the unit description text box)
* A history of all battles (Player and AI) is presented to the player within the "Lists" menu by double-clicking the "Regions" tab. 

> NOTE: "mod mach_battle_chronicler.pack;" must be added to your "C:\Users\<user>\AppData\Roaming\The Creative Assembly\Empire\scripts\user.empire_script.txt" file in order for mod "Machiavelli's Battle Chronicler" to be enabled.


## How to Install
1. Copy all files from [Github repository](https://github.com/szmania/MACH_armchair_general_mods/releases) into your Empire Total War directory and overwrite. I advise using [JSGME](https://www.filecroco.com/download-jsgme/) for this. (the empire_start_wali_mach.bat file should be in the same directory as your Empire.exe file, ie: C:\Program Files (x86)\Empire Total War)
2. Add mod packs to your "C:\Users\<user>\AppData\Roaming\The Creative Assembly\Empire\scripts\user.empire_script.txt" file.
ie:
```mod mach_battle_chronicler.pack;```
(each mod pack name should be on its own line)
3. Run with empire_start_wali_mach.bat file. This will start WALI and Empire Total War, or a compatible mod launcher. Currently supported mod launchers are ACW Brother vs. Brother, Imperial Splendour and Darth Mod Empire Platinum. The .bat file will monitor if Empire.exe/Mod Launcher is running and kill WALI when Empire.exe/Mod Launcher closes.

## Is it Compatible with my mods?
Machiavelli's Armchair General Mods should be compatible with ALL mods.

#### VadAntS Disease Mod (VDM) compatibility
Edit your `user.empire_script.txt` file, as you would normally. Just be sure to include your MACH mod packages with the VDM packages like so:
```
mod VDM.pack;
mod VDM_DP.pack;
mod VDM_src.pack;
mod ui_vdm.pack;
mod Replenishment.pack;
mod mach_battle_chronicler.pack;
```
Then launch the mod using `empire_start_wali_mach.bat`, as you normally would.

The `empire_start_wali_mach.bat` script automatically edits `data/campaigns/main/scripting.lua` file, but if that fails please edit that file manually.
From (line 1124):
```
events.PanelOpenedCampaign[#events.PanelOpenedCampaign+1] = function (context)
	oldSavegameList = CampaignUI.EnumerateCampaignSaves(path,"*")
	if justSaved then
		conductSave()
	end
	justSaved = false
end

```
To:
```
events.PanelOpenedCampaign[#events.PanelOpenedCampaign+1] = function (context)
	if path then
		oldSavegameList = CampaignUI.EnumerateCampaignSaves(path,"*")
		if justSaved then
			conductSave()
		end
		justSaved = false
	end
end 
```




## Found a Bug???
Post bugs [HERE](https://github.com/szmania/MACH_armchair_general_mods/issues)

1. Please describe the bug.
2. Please list any mods you are using.
3. Please post the Mach Mod log file (the mach_lua.log file found in "C:\Program Files (x86)\Empire Total War\data\WALI\Logs\mach_lua.log")
4. Please post the Mach Mod save game file. (will be the same name as your saved game, found in "C:\Users\<user>\AppData\Roaming\The Creative Assembly\Empire\save_games\mach_mod\")
