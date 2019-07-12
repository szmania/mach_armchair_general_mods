----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
---------------------Warscape Added Lua Interface---------------------------------
-------------------------Empire TW Lua Interface----------------------------------
-----------------------------------v1.0-------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

module(..., package.seeall)

local WALI_m_root = nil --the UI root
local WALI_m_root_found = false
local WALI_LogCount = 0
local WALI_isOnCampMap = false
local WALI_isFirstClickOnArmy = false
local WALI_armyIsSelected = false
local scripting = require "EpisodicScripting"
local WALI_previouslySelectedCharacterPointer = nil
local env = ""
local expansionFile = ""
local manisfestLoaded = false
local manifestError = ""
local configLoaded = false
local configError = ""
local debugMode = true
local configFile = ""
--[[--------------------------------------------------------------------------------
		Section A:
			Interface Writing/Reading
----------------------------------------------------------------------------------]]


--[[
Description:
	Creates a .WALI file in the relevant interface directory
Arguments:
	Number(hex) base_pointer
		Memory pointer to the current object being operated upon

	String command_type
		A valid wali mach_logistics_pip# command. Valid commands are defined in the folder
		WALI\Engine\Commands

	String command_argument
		Argument to pass to the above command.  Multiple part arguments must be passed
		in as one whole string. 

	String optionalHeader
		Optional string that will be appended to the top of the .WALI file being created.  Primarily used
		for debugging, unless anything goes wrong the file will be deleted in a matter of seconds.  Can be left empty
Returns:
	n/a
--]]
function CreateWALIInterfaceLog(base_pointer, command_type, command_argument, optionalHeader)
	local s = "#"
	if type(optionalHeader) == "nil" then
		s = s.."No header"
	else
		s = s..optionalHeader
	end

	local WALIInterface = io.open("data/WALI/Interface/LW/"..WALI_LogCount..".WALI","w")
	WALIInterface:write(tostring(s).."\n"..tostring(base_pointer)..";"..tostring(command_type)..";"..tostring(command_argument))
	WALIInterface:close()
	WALI_LogCount = WALI_LogCount + 1
end

--[[--------------------------------------------------------------------------------
		Section A.1:
			Logging functions
				Used for creating and writing to logs
----------------------------------------------------------------------------------]]

--[[
Description:
	Creates a new Lua log in the logging directory
Arguments:
	n/a
Returns:
	n/a
--]]
local function CreateNewWALILuaLog()
	local ErrorLog = io.open("data/WALI/Logs/Lua Log.txt","w")
	local DateAndTime = os.date("%H:%M.%S")
	ErrorLog:write("Log Created: "..DateAndTime)
	ErrorLog:close()
end

--[[
Description:
	Writes to the log file

Arguments:
	String update_arg
		Text to write to the log
Returns:
	n/a
--]]
function UpdateWALILuaLog(update_arg)
	if not debugMode then
		return 
	end
	local DateAndTime = os.date("%H:%M.%S")
	local U_Log = io.open("data/WALI/Logs/Lua Log.txt","a")
	if type(update_arg) ~= "nil" then
		U_Log:write("\n["..DateAndTime.."]\t\t"..tostring(update_arg))
	elseif type(update_arg) == "nil" then
		U_Log:write("\n["..DateAndTime.."]\t\tLogging error: input type nil")
	end
	U_Log:close()
end

--[[--------------------------------------------------------------------------------
		Section B:
			WALI Commands
----------------------------------------------------------------------------------]]

--All WALI commands are checked for relevant validity as much as possible on the Lua side; this means
--checking that the correct types are forwared to the .WALI file and no null data escapes Lua.

--WALI memory commands have been moved to individual files in the /Engine/Commands directory. 17/06/13


--[[
Description:
	Displays a message to the user.  Note that this isn't comparable to any form of "throw" statement; it doesn't alter
	control flow at any stage, nor prevent execution of bad code. It's a bit optimisticly named!

Arguments:
	String errorText
		Message to display.  Will be prefixed by "WALI has encountered an error:"
Returns:
	n/a
--]]
function throwIngameWALIError(errorText)
	local utils = require("Utilities")
	local panel_manager = utils.Require("panelmanager")
	--All stuff imported, open it up
	panel_manager.OpenPanel("dialogue_box", false, "Initialise", "WALI has encountered an error:\n"..tostring(errorText))
end

--[[
Description:
	Reads a wali return file (used by hardcoded commands)
	As this function can get called before WALI.exe has disposed of the return file, it
	can encounter file permission errors.  To prevent this, it loops while trying to read the file.
	If the loop hits iteration 2000 it displays an error message - if all is working correctly it
	will normally pick up the file are 4 or 5 loops
Arguments:
	n/a
Returns:
	File contents if successful, else false
--]]
function readWALIReturnFile()
	local filePath = "data/WALI/Interface/WL/output.return"
	local search = true
	local i = 0 --search loop tracking
	local value = nil
	local fileOpened = false
	
	--note that at this stage the file can be opened simultaneously in lua and C# (as lua opens it read-only)
	--due to this lua can open the file and read it as C# is writing - see below for solution
	while not fileOpened do
		UpdateWALILuaLog("readWALIReturnFile, Attempt "..tostring(i).." to open "..tostring(filePath))
		i = i + 1
		if i > 900000 then
			throwIngameWALIError("Function readWALIReturnFile has encountered an error (Error code 2) - WALI has potentially crashed, or is not responding\nWALI is now in an inconsistent state, please exit your game and report this error. Continued game play after this problem could corrupt your save game.")
			return false
		end
		local e = 1
		if fileExistsForRead(filePath) then
			local contents = nil
			local f = nil
			--solution to above problem - keep looping until file contents don't equal nil (the attrition return file should *always* have something in it when C# is finished with it)
			while contents == nil do
				e = e + 1
				if e > 2000 then
					throwIngameWALIError("Function readWALIReturnFile has encountered an error (Error code 2a) - WALI has potentially crashed, or is not responding\nWALI is now in an inconsistent state, please exit your game and report this error. Continued game play after this problem could corrupt your save game.")
					return false
				end
				f = io.open(filePath, "r")
				UpdateWALILuaLog("\treadWALIReturnFile, Success. Handle:"..tostring(f))
				contents = f:read()
				UpdateWALILuaLog("\treadWALIReturnFile, Success. File Contents: "..tostring(contents)..", Attempt: "..tostring(e))
				f:close()
			end
			if contents == "0" then
				value = false
			elseif contents == "1" then
				value = true
			else
				value = contents
			end			--attempt to delete the file; if it fails, inform the user. deleteFile logs failure internally
			if not deleteFile(filePath) then
				throwIngameWALIError("Function readWALIReturnFile has encountered an error (Error code 3) - WALI has potentially crashed, or is not responding\nWALI is now in an inconsistent state, please exit your game and report this error. Continued game play after this problem could corrupt your save game.")
				return false
			end
			fileOpened = true
			UpdateWALILuaLog("\treadWALIReturnFile, Success. Returning: "..tostring(value)..", Total contents: "..tostring(contents).."\t, Handle:"..tostring(f))
			break
		else
			UpdateWALILuaLog("\treadWALIReturnFile, Could not find or access "..tostring(filePath))
		end
	end
	return value
end

--[[--------------------------------------------------------------------------------
		Section B_1:
			WALI Commands; generic Lua extension
----------------------------------------------------------------------------------]]

--[[
Description:
	Checks if a file exits for reading, or is accessible to read.
Arguments:
	String fileName
		File path to file
Returns:
	True if accessible, else false
--]]
function fileExistsForRead(fileName)
	local f = io.open(fileName, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

--[[
Description:
	Deletes a file at the given location.  It will loop over the file and attempt to delete until it has been deleted, up to 2000 attempts
	Note that this is case insensitive: A == a, B == b etc
Arguments:
	String fileName
		File path to file
Returns:
	true for success, else false
--]]
function deleteFile(fileName)
	UpdateWALILuaLog("Deleting file: "..tostring(fileName))
	local i = 0
	fail = os.remove(fileName) --returns nil if failed, true if successful
	while fail == nil do
		UpdateWALILuaLog("deleteFile, File deletion failed on attempt: "..tostring(i)..", retrying")
		i = i + 1
		fail = false
		fail = os.remove(fileName)
		if i > 5000 then
			UpdateWALILuaLog("Failed to delete file: "..tostring(fileName))
			return false
		end
	end
	UpdateWALILuaLog("Successfully deleted file: "..tostring(fileName))
	return true
end

--[[
Description:
	Gets a random whole or decimal number
Arguments:
	bool isDecimal
		If true returns random decimal, else returns random integer
Returns:
	Random number
--]]

function getRandomNumber(isDecimal)
	local DateAndTimeRandNum = os.clock()
	local Num_1, Test_Num = math.modf(DateAndTimeRandNum)
	local Rand_Num_table = {}
	for i = 1, 100 do
		Rand_Num_table[i] = math.random(1, 100)
	end
	local Num_2 = (math.ceil((DateAndTimeRandNum - Num_1) * 100))
	if isDecimal then
		return Rand_Num_table[Num_2] - Test_Num
	else
		return Rand_Num_table[Num_2]
	end
end

--[[
Description:
	Removes 0x prefix from hexadecimal address's
	Note that this is not a generic function, the string indices are fixed (line 384)
Arguments:
	String address
		Hexadecimal annotated address
Returns:
	Hex number without 0x prefix, as string
--]]
function convertCAAddressToHexPointer(address)
	local s = tostring(address)
	return string.sub(s, #s-9, #s - 1)
end


--[[--------------------------------------------------------------------------------
		Section D:
			Miscellaneous & WALI init
----------------------------------------------------------------------------------]]
--[[
	Description:
		Informs user that the WALI lua module has successfully loaded, includes a check to see if WALI is still running
		Does not mean that the Lua code has loaded error-free.
	Arguments:
		n/a
	Returns:
		n/a
--]]
local function InformSuccessfullWALIStart()
	UpdateWALILuaLog("InformSuccessfullWALIStart - Started")
	CheckWALIStatus("Checking from InformSuccessfullWALIStart")
	local utils = require("Utilities")
	local panel_manager = utils.Require("panelmanager")

	local filePath = "data/WALI/Interface/WL/startup.txt"
	local found = false;
	local i = 0
	while not found do
		i = i + 1
		if i > 2000 then
			found = false
			break
		end
		if fileExistsForRead(filePath) then
			found = true
			deleteFile(filePath)
			break
		end
	end
	if found then
		--All stuff imported, open it up
		panel_manager.OpenPanel("dialogue_box", false, "Initialise", "WALI has successfully started")
	else
		--All stuff imported, open it up
		panel_manager.OpenPanel("dialogue_box", false, "Initialise", "WALI has failed to start (Error code 1) - WALI has potentially crashed, or is not responding\nWALI is now in an inconsistent state, please exit your game and report this error. Continued game play after this problem could corrupt your save game.")
	end
	UpdateWALILuaLog("InformSuccessfullWALIStart - Finished")
end

--[[
	Description:
		Loads a user defined command from the /Engine/Commands directory.
	Arguments:
		String name:
			The name of the command file to load
	Returns:
		True for success, else sting containing error details
--]]
local function loadUserDefinedCommand(name)
	expansionFile = loadfile("data/WALI/Engine/Commands/"..name)
	if type(expansionFile) == "nil" then
		UpdateWALILuaLog(name.." failed, does not exist")
		return ("The command "..name.." could not be loaded. WALI is now in an inconsistent state and should not be used further until this error is resolved.")
	end
	setfenv(expansionFile, env)
	expansionFile()
	return true
end

--[[
	Description:
		Loads the WALI config file
	Arguments:
		n/a
	Returns:
		True for success, else sting containing error details
--]]
local function loadWALIConfigFile()
	configFile = loadfile("data/WALI/Config.lua")
	if type(configFile) == "nil" then
		UpdateWALILuaLog(name.." failed, does not exist")
		return ("The file "..name.." could not be loaded. WALI is now in an inconsistent state and should not be used further until this error is resolved.")
	end
	setfenv(configFile, env)
	configFile()
	UpdateWALILuaLog("Loaded config: "..tostring(WALI_attritionMinRate).."\t"..tostring(WALI_attritionMaxRate))
	return true
end

--[[
	Description:
		Reads the commands manifest and loads all specified commands
	Arguments:
		n/a
	Returns:
		True for success, else string containing error info
--]]
local function readManifest()
	for line in io.lines("data/WALI/Engine/Commands/manifest.txt") do
		UpdateWALILuaLog("Loading command extension "..tostring(line))
		loadAttempt = loadUserDefinedCommand(line)
		if loadAttempt ~= true then
			return loadAttempt
		end
	end
	return true
end

--[[
	Description:
		More basic initialisation
	--]]
CreateNewWALILuaLog()
env = getfenv()
--Read the manifest and load up all the commands
manifestInfo = readManifest()
if type(manifestInfo) ~= "string" then
	UpdateWALILuaLog("Manifest Read Success")
	manisfestLoaded = true
else
	UpdateWALILuaLog("Manifest Read Fail")
	manifestError = manifestInfo
end
--Load the config file
configError = loadWALIConfigFile()
if type(configError) ~= "string" then
	configLoaded = true
	UpdateWALILuaLog("Config Read Success")
	debugMode = isDebugMode
else
	UpdateWALILuaLog("Config Read Fail")
	configLoaded = true
end

events.UICreated[#events.UICreated+1] = function(context)
	--Make sure the battle UI isn't after loading
	if context.string == "Campaign UI" then
		WALI_isOnCampMap = true
		--used for accessing and working with UI components
		WALI_m_root = UIComponent(context.component)
		WALI_m_root_found = true
		if not manisfestLoaded then
			throwIngameWALIError("Could not load from manifest. Details:\n"..manifestError)
		elseif not configLoaded then
			throwIngameWALIError("Could not load from config file. Details:\n"..configError)
		else
			InformSuccessfullWALIStart()
		end
	else
		WALI_isOnCampMap = false
	end
end



--[[--------------------------------------------------------------------------------
		TEST CODE
----------------------------------------------------------------------------------]]
--[[	events.ComponentLClickUp[#events.ComponentLClickUp+1] = function(context)
		local ETS = CampaignUI.EntityTypeSelected()
		if ETS.Character then
			UpdateWALILuaLog("Char table")
			charDetails = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
			entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(ETS.Entity, ETS.Entity)
			for k, v in pairs(charDetails) do
				UpdateWALILuaLog(tostring(k).."\t"..tostring(v))
				if type(v) == "table" then
					for kk, vv in pairs(v) do
						UpdateWALILuaLog("\t\t"..tostring(kk).."\t"..tostring(vv))
						if type(vv) == "table" then
							for kkk, vvv in pairs(vv) do
								UpdateWALILuaLog("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							end
						end
					end
				end
			end
		elseif ETS.Unit then
			UpdateWALILuaLog("Unit table")
			charDetails = CampaignUI.InitialiseUnitDetails(ETS.Entity)
			for k, v in pairs(charDetails) do
				UpdateWALILuaLog(tostring(k).."\t"..tostring(v))
				if type(v) == "table" then
					for kk, vv in pairs(v) do
						UpdateWALILuaLog("\t\t"..tostring(kk).."\t"..tostring(vv))
						if type(vv) == "table" then
							for kkk, vvv in pairs(vv) do
								UpdateWALILuaLog("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							end
						end
					end
				end
			end
		end
	end	--]]

--[[--------------------------------------------------------------------------------
		Section C:
			Attrition Implementation
----------------------------------------------------------------------------------]]


local armyInfotable = {
	["StartingPoints"] = 0,
	["CharacterAddress"] = nil,
	["LastPointsSample"] = nil
	}


--Game's lua doesn't have great support for non-English chars (not too sure what encoding it is).
--As such, I've replaced the problematic names with the characters that Lua will recognise.  The code I used to work out the names causing issues
--can be seen in WALI/Misc/settlementnames.lua.  Could be used to check custom settlement names if needed
--N.B. - "Fort" is the generic name given to the location of any army in a fort NOTE: Inconsistent. Daniel, 11/07/13
--N.B. 2 - This is not actually in use anymore, but I'm keeping it in case it's needed again. Daniel 17/06/13.
local settlementsTable = {"Fort", "Fort Nashwaak", "Louisbourg", "Kabul", "Ahmadnagar", "Algiers", "Niagara", "Strasbourg", "Ankara", "Arkhangelsk",
			"Yerevan", "Astrakhan", "Vienna", "Ardabil", "Nassau", "Zahedan", "Ufa", "Munich", "Minsk", "Calcutta", "Nagpur", "Satara", "Prague", "Sarajevo",
			"Sofia", "Arcot", "Charleston", "Trincomalee", "Tarki", "Tellico", "Bastia", "Jelgava", "Bakhchisaray", "Zagreb", "La Habana", "Punda", "Copenhagen",
			"Cherkassk", "Paramaribo", "Cairo", "London", "Riga", "Åbo", "Brussels", "St. Augustine", "Paris", "Cayenne", "Lwów", "Genoa", "Tbilisi", "Savannah",
			"Gibraltar", "Knife River Village", "Athens", "Antigua Guatemala", "Ahmedabad", "Hannover", "Agra", "Santo Domingo", "Preßburg", "Fort Sault Ste. Marie",
			"Hyderabad", "Reykjavík", "St. Petersburg", "Dublin", "Cayuga", "Port Royal", "Tanase", "Petrovskaya Sloboda", "Srinagar", "Ust-Sysolsk", "Agvituk",
			"Antigua", "Vilnius", "New Orleans", "Falmouth", "Goa", "Valletta", "Ujjain", "Annapolis", "Baghdad", "Fort Pontchartrain du Detroit", "Milan", "Iaşi",
			"Patras", "Tangier", "Moscow", "Mysore", "Naples", "Amsterdam", "Caracas", "Boston", "Boston", "Qu�bec", "Québec", "Bogotá", "Santa Fe", "México",
			"Albany", "Plaissance", "York Factory", "Christiania", "Montréal", "Cuttack", "Jerusalem", "Panama", "Philadelphia", "Philadelphia", "Isfahan", "Warsaw",
			"Lisbon", "Königsberg", "Lahore", "Udaipur", "Cologne", "Istanbul", "Moose Factory", "Cagliari", "Turin", "Dresden", "Edinburgh", "Belgrade", "Breslau",
			"Neroon Kot", "Madrid", "Stockholm", "Damascus", "Kazan", "Villa de Bexar", "Rome", "Klausenburg", "San José de Oruña", "Tripoli", "Tunis", "Kiev",
			"Fort de Chartres", "Venice", "Williamsburg", "Berlin", "Gdańsk", "Martinique", "Stuttgart", "Yankton", "Chicasa", "Akbarabad", "Esfahan"
			}


--[[
Description:
	Attrition initialisation.
	Must be called in order for attrition to work
Arguments:
	n/a
Returns:
	n/a
--]]

function InitialiseAttrition()

	--########################
	--Variable Declaration
	--########################
	--table containing all player owned regions
	playerOwnedRegions = {}
	--table containing all player owned and allied regions
	safeRegionsAndSettlements = {}
	--[[--------------------------------------------------------------------------------
		Subsection C (i):
			UI interfacing
	----------------------------------------------------------------------------------]]
	--[[
	Description:
		Mouse click event
			Used to turn off timers when player clicks away from an army
			Timers = computing black hole
	--]]
	events.ComponentLClickUp[#events.ComponentLClickUp+1] = function(context)
		if WALI_isOnCampMap then
			local ETS = CampaignUI.EntityTypeSelected()
			if not ETS.Character and not ETS.Unit then
				WALI_isFirstClickOnArmy = false
				WALI_armyIsSelected = false
				--set this to nil here in case player clicks army X -> other non-army object -> army x again,
				--in which case checks would fail
				WALI_previouslySelectedCharacterPointer = nil
			end
		end
	end
	--[[
	Description:
		Character selected event
			Used to start timers off
	--]]
	events.CharacterSelected[#events.CharacterSelected+1] = function(context)
		if WALI_isOnCampMap and (conditions.CharacterType("General", context) or conditions.CharacterType("colonel", context)) then
			local ETS = CampaignUI.EntityTypeSelected()
			WALI_armyIsSelected = true
			--WALI_isFirstClickOnArmy prevents the code from piling up and overloading memory, as each left click of the mouse
			--would start firing off triggers and WALI data requests
			if WALI_previouslySelectedCharacterPointer ~= ETS.Entity then
				WALI_isFirstClickOnArmy = true
			end

			if WALI_isFirstClickOnArmy then
				--reset this here, to prevent rare bug where currently selected army's movepoints equal that
				--of the previously selected army's MP's after it moved
				armyInfotable.LastPointsSample = nil
				if conditions.CharacterType("General", context) then
					charDetails = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
					armyInfotable.CharacterAddress, WALI_previouslySelectedCharacterPointer = ETS.Entity
				elseif conditions.CharacterType("colonel", context) then
					local unitDetails = CampaignUI.InitialiseUnitDetails(ETS.Entity)
					charDetails =  CampaignUI.InitialiseCharacterDetails(unitDetails.CharacterPtr)
					armyInfotable.CharacterAddress, WALI_previouslySelectedCharacterPointer = unitDetails.CharacterPtr
				end
				--UpdateWALILuaLog("\tCharacterSelected, Finding pip")
				local c = WALI_m_root:Find("WALI_AttritionPip")
				--UpdateWALILuaLog("\t\tCharacterSelected, Found pip!")
				
				--if the character is in a friendly region don't bother requesting positional from wali
				if isCharacterInSafeRegion(armyInfotable.CharacterAddress) or isLocationAFort(CampaignUI.InitialiseCharacterDetails(armyInfotable.CharacterAddress).Location) then
					UpdateWALILuaLog("\t\tCharacter is in a friendly region, setting pip without WALI call")
						UIComponent(c):SetState("NoAttrition")
						UpdateWALILuaLog("\tCharacterSelected, NoAttrition")
						UIComponent(c):SetTooltipText("This army is not suffering attrition")
						UIComponent(c):SetVisible(true)
				else
					--character isn't in a safe region (or a fort in enemy territory), so disable replenishment
					setReplenishTooltip("This army is not in a friendly region and it's units cannot be replenished")
					enableReplenishButton(false)
					enableFortButton(true)
					setReplenishTooltip("This army is not in a friendly region and it's units cannot be replenished")
					--set the attrition pip and tooltip
					UIComponent(c):SetState("HasAttrition")
					UIComponent(c):SetTooltipText("This army is suffering attrition")
					UIComponent(c):SetVisible(true)	
				end
				--UpdateWALILuaLog("CharacterSelected, Is first click on army, starting points: "..tostring(charDetails.ActionPoints))
				--if character hasn't any movepoints we dont need to waste time watching for changes
				if charDetails.ActionPoints ~= 0 then
					armyInfotable.StartingPoints = charDetails.ActionPoints
					--UpdateWALILuaLog("\tCharacterSelected, Trigger queuing")
					scripting.game_interface:add_time_trigger("MoveWatch", .5)
					--UpdateWALILuaLog("\tCharacterSelected, Trigger queued")
				end
			else
				UpdateWALILuaLog("\tCharacterSelected, Trigger not queued")
			end
		end
	end
	
	--[[
	Description:
		Monitors movepoint changes, using time triggers to perform checks.
		When movepoints change a WALI interface file is wrote.
	Arguments:
		Number startingPoints
			Starting move points of the given entity.  Movement is monitored by
			checking against this number.
		Number address
			Memory address of the entity
		bool isCharacter
			Is the entity a named character? Admirals and generals are characters, colonels
			and captains are not
	Returns:
		n/a
	--]]
	function watchForChanges(startingPoints, address, IsCharacter)
		local charDetails = CampaignUI.InitialiseCharacterDetails(address)
		--if unit is moving...
		if charDetails.ActionPoints ~= startingPoints and charDetails.ActionPoints ~=  armyInfotable.LastPointsSample then
			local c = WALI_m_root:Find("WALI_AttritionPip")
			--if the character is in a friendly region don't bother requesting positional from wali
			if isCharacterInSafeRegion(address) or isLocationAFort(CampaignUI.InitialiseCharacterDetails(address).Location) then
				UpdateWALILuaLog("\t\tCharacter is in a friendly region, setting pip without WALI call")
				UIComponent(c):SetState("NoAttrition")
				--UpdateWALILuaLog("\watchForChanges, NoAttrition")
				UIComponent(c):SetTooltipText("This army is not suffering attrition")
				UIComponent(c):SetVisible(true)
			else
				--character isn't in a safe region (or a fort in enemy territory), so disable replenishment
				setReplenishTooltip("This army is not in a friendly region and it's units cannot be replenished")
				enableReplenishButton(false)
				enableFortButton(true)
				setReplenishTooltip("This army is not in a friendly region and it's units cannot be replenished")
				--set the attrition pip and tooltip
				UIComponent(c):SetState("HasAttrition")
				UIComponent(c):SetTooltipText("This army is suffering attrition")
				UIComponent(c):SetVisible(true)
			end
			--if character hasn't any movepoints we dont need to waste time watching for changes
			if charDetails.ActionPoints ~= 0 then
				armyInfotable.StartingPoints = charDetails.ActionPoints
				--UpdateWALILuaLog("\watchForChanges, Trigger queuing")
				scripting.game_interface:add_time_trigger("MoveWatch", .5)
				--UpdateWALILuaLog("\watchForChanges, Trigger queued")
			end
			
			armyInfotable.LastPointsSample = charDetails.ActionPoints
		else
			scripting.game_interface:add_time_trigger("MoveWatch", .5)
		end
	end

	--[[
	Description:
		Time trigger event
	--]]
	events.TimeTrigger[#events.TimeTrigger+1] = function(context)
		--context.string is the name passed when the trigger was fired (see line 563)
		if context.string == "MoveWatch" and WALI_armyIsSelected then
			watchForChanges(armyInfotable.StartingPoints, armyInfotable.CharacterAddress, true)
		end
	end

	--[[--------------------------------------------------------------------------------
		Subsection C (ii):
			Attrition Calculations
	----------------------------------------------------------------------------------]]
	--[[
	Description:
		Faction Turn Start event.  From here attrition calculations are made
	--]]
	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		if conditions.IsPlayerTurn(context) and conditions.TurnNumber(context) >= 0 then
			updateSafeRegionsAndSettlements()
			--Loop through all player land forces
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(CampaignUI.PlayersFactionKey(), true)
			for i = 1, #forcesList do
				--check if the character is in a hostile region and not in a city
				--city must be checked as garrisoned forces location will show as the city of residence, which
				--would not register as an owned region
				if not isRegionAttritionSafe(forcesList[i].Location) and not isLocationAFort(forcesList[i].Location) then
					UpdateWALILuaLog("\t"..forcesList[i].Location.." is not player owned")
					--and do stuff related to attrition from here...
					--first thing, get return data
					--local readValue = readWALIReturnFile()
					--if readValue then
						local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
						for k,v in pairs(entities.Units) do
							local damage, reference = calculateAttritionDamage(v.Men)
							SetCurrentUnitSize(v.Address, damage, "Unit: "..tostring(v.Name).."Commanders Name: "..tostring(v.CommandersName).."Random number reference: "..tostring(reference))
							SetUnitReplenishable(v.Address, v.UnitRecord.Men, "Setting \"replenish to\" value to"..v.UnitRecord.Men)
						end
				else
					UpdateWALILuaLog("\t"..forcesList[i].Location.." is player owned")
				end
			end
		end
	end

	
	events.UICreated[#events.UICreated+1] = function(context)
		--Make sure the battle UI isn't after loading, then update safe region and settlements; This accounts for
		--loading save games, returning from battles and starting new games
		if context.string == "Campaign UI" then
			OK, Error = pcall(updateSafeRegionsAndSettlements)
			if not OK then
				UpdateWALILuaLog(Error)
			end
		end
	end
	
	--[[--------------------------------------------------------------------------------
		Subsection C (iii):
			Attrition helper functions
	----------------------------------------------------------------------------------]]
	--[[
	Description:
		Calculates attrition damage based on attrition variables read from a config file.
	Arguments:
		Number currentUnitSize
			Current size of unit to calculate damage for
	Returns:
		New size of unit (post damage)
	--]]
	function calculateAttritionDamage(currentUnitSize)

		local randNum = getRandomNumber(true)
		while randNum > WALI_attritionMaxRate or randNum < WALI_attritionMinRate do
			randNum = getRandomNumber(true)
		end
		return currentUnitSize - math.ceil(currentUnitSize / 100 * randNum), randNum
	end

	
	--[[
	Description:
		Finds out if a region is attrition safe (i.e. owned by player or an ally)
	Arguments:
		String region
			Name of the region
	Returns:
		True if owned, else false
	--]]
	function isRegionAttritionSafe(region)
		UpdateWALILuaLog("Checking if "..region.." is attrition safe.")
		for i = 0, #safeRegionsAndSettlements do
			if safeRegionsAndSettlements[i] == region then
				UpdateWALILuaLog(region.." is attrition safe.")
				return true
			end
		end
		return false
	end
	
	--[[
	Description:
		Updates the list of player owned and allied regions. Should be called on game load, turn start and when campaign is entered
	Arguments:
		n/a
	Returns:
		n/a
	--]]
	function updateSafeRegionsAndSettlements()
		UpdateWALILuaLog("Updating safe regions")
		--reset the table on each call to prevent accidental bloating
		safeRegionsAndSettlements = {}
		--the table returned here has more info than we need, so take the region name from each entry
		_regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(CampaignUI.PlayerFactionId())
		local i = 1
		for k, v in pairs(_regions) do
			safeRegionsAndSettlements[i] = _regions[k].Name
			i = i + 1
			safeRegionsAndSettlements[i] = CampaignUI.InitialiseRegionInfoDetails(_regions[k].Address).Settlement
			i = i + 1
		end
		
		--get allied regions
		local playerDiplomacyDetails = CampaignUI.RetrieveDiplomacyDetails(CampaignUI.PlayersFactionKey())
		--Update("Looping through allies")
		for k,v in pairs(playerDiplomacyDetails.Allies) do
			local thisFactionsRegions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(k)
			for kk, vv in pairs(thisFactionsRegions) do
				safeRegionsAndSettlements[i] = thisFactionsRegions[kk].Name
				i = i + 1
			end
		end
	end
	
	--[[
	Description:
		Finds out if a character is in an attrition safe region
	Arguments:
		Pointer characterPointer
			Address of the character / Pointer to the character
	Returns:
		True if the character is in a friendly region, else false
	--]]
	function isCharacterInSafeRegion(characterPointer)
		charDetails = CampaignUI.InitialiseCharacterDetails(characterPointer)
		return isRegionAttritionSafe(charDetails.Location)
	end
	
	--[[
	Description:
		Finds out if a region is a fort (will return true for cities with fort in the name, 
		that shouldn't be an issue though)
	Arguments:
		String location
			Name of the location
	Returns:
		True if owned, else false
	--]]
	function isLocationAFort(location)
		UpdateWALILuaLog("Checking if "..location.." is a fort.")
		--Fort names are randomly generated, but always start with "Fort".
		--look for "Fort" substring in location name to check if it's a fort
		if not (string.find(location, "Fort") == nil) then
			UpdateWALILuaLog(location.." is a fort.")
			return true
		end
	end
	--[[
	Description:
		Changes the replenish button's state
	Arguments:
		Bool enable
			True to set it to state normal, false to set it to state inactive
	Returns:
		n/a
	--]]
	function enableReplenishButton(enable)
		local c = WALI_m_root:Find("army_replenish")
		if enable then
			UIComponent(c):SetState( "normal" )
		else
			UIComponent(c):SetState( "inactive" )
		end
	end
	
	function enableFortButton(enable)
		local c = WALI_m_root:Find("army_fort")
		if enable then
			UIComponent(c):SetTooltipText("Cost: 1500\nBuild Fort||Building a fort requires a general and you must be within your own region.||If your army is on the move and vulnerable it may be wise to build a fort for protection||I bet no one is even reading this")
			UIComponent(c):SetState( "normal" )
			UIComponent(c):SetTooltipText("Cost: 1500\nBuild Fort||Building a fort requires a general and you must be within your own region.||If your army is on the move and vulnerable it may be wise to build a fort for protection||I bet no one is even reading this")
		else
			UIComponent(c):SetState( "inactive" )
		end
	end
	
	
	--[[
	Description:
		Changes the replenish button's tooltip
	Arguments:
		String arg
			The text to set the tooltip to.
	Returns:
		n/a
	--]]
	function setReplenishTooltip(arg)
		local c = WALI_m_root:Find("army_replenish")
		UIComponent(c):SetTooltipText(tostring(arg))
	end
end
