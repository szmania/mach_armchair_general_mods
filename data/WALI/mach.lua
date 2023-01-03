module(..., package.seeall)


--wali = require "WALI/WALI"
mach_lib = require "WALI/mach_lib"
mach_data = require "WALI/mach_data"
mach_config = require "WALI/mach_config"
--ti_lib = require "WALI/TI_lib"

__mach_features_enabled__ = {}

__mach_enabled_mods_msg_box_displayed__ = false

local scripting = require "EpisodicScripting"
--local utils = require("utilities")
--local core = require("CoreUtils")
--local out = require("out")


local prevContext = nil
local prevCallTime = nil
local selectedCharacterContext = nil
local env = ""
local configError = ""
local configFile = ""


local region_names_list = {}
local settlement_names_list = {}
local artillery_to_gun_type_list = {}
--local besiegedSettlements_list = {}

local function _get_mach_enabled_mods_list()
	mach_lib.update_mach_lua_log("Getting MACH enabled mods list.")
	local save_game_extension, save_game_path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
	local game_mod_scripts_file_path
	if mach_lib.is_empire_total_war() then
		game_mod_scripts_file_path = save_game_path:gsub("save_games\\", "scripts\\user.empire_script.txt")
	else
		game_mod_scripts_file_path = save_game_path:gsub("save_games\\", "scripts\\user.script.txt")
	end

	mach_lib.update_mach_lua_log(save_game_path)
	mach_lib.update_mach_lua_log(game_mod_scripts_file_path)
	local game_mod_scripts_file_path_new = string.format('%s.new', game_mod_scripts_file_path)

	local powershell_cmd = string.format('powershell -Command "& {Get-Content \'%s\' | Set-Content -Encoding ascii \'%s\'}"', game_mod_scripts_file_path, game_mod_scripts_file_path_new)
	mach_lib.update_mach_lua_log(string.format('Executing batch cmd: %s', powershell_cmd))
	os.execute(powershell_cmd)
	local game_enabled_mods_list = mach_lib.read_lines_from_file(game_mod_scripts_file_path_new)

	local mach_enabled_mods_list = {}
	for line_num, game_enabled_mod in pairs(game_enabled_mods_list) do
		local mach_mod_name = game_enabled_mod:gsub("mod ", ""):gsub(";",""):gsub('"',''):gsub('.pack','')
		mach_lib.update_mach_lua_log(string.format('Mach mod "%s" is enabled.', mach_mod_name))
		mach_enabled_mods_list[#mach_enabled_mods_list+1] = tostring(mach_mod_name)
	end
	local del_cmd = string.format('del "%s"', game_mod_scripts_file_path_new)
	mach_lib.update_mach_lua_log(string.format('Executing batch cmd: %s', del_cmd))
	os.execute(del_cmd)
	mach_lib.update_mach_lua_log("Finished getting MACH enabled mods list.")
	return mach_enabled_mods_list
end


-- Initialise MACH 
function initialize_mach()
--	mach_lib.set_debug(true)

--	mach_lib.create_mach_lua_log()
	mach_lib.update_mach_lua_log("Initializing Machiavelli's Mods.")
	mach_data.__mach_saved_games_list__ = mach_lib.get_mach_saved_games_list()

	local mach_enabled_mods_list = _get_mach_enabled_mods_list()
	if mach_lib.is_value_in_table('mach_battle_chronicler', mach_enabled_mods_list) then
		mach_lib.update_mach_lua_log('MACH - Battle Chronicler is enabled.')
		mach_battle_chronicler = require "WALI/mach_battle_chronicler"
		mach_battle_chronicler.mach_battle_chronicler()
	end


--	mach_lib.load_mach_config_file()
	--mach_lib.__mach_log_func_name__("MACH.initialise_mach")


--	local alphaPointer = wali.GetAlphaPointer('0x017F1C80', optionalHeader)
--	mach_lib.update_mach_lua_log("campaign_unit_multiplier: "..tostring(wali.GetCampaignUnitMultiplier(nil)))

	--	region_names_list = mach_lib.build_region_names_list()
--	settlement_names_list = mach_lib.build_settlement_names_list()
--	artillery_to_gun_type_list = mach_lib.build_artillery_to_gun_type_list()

	mach_lib.update_mach_lua_log("Finished Initializing Machiavelli's Mods.")
end

--[[
	Description:
		Loads the WALI config file
	Arguments:
		n/a
	Returns:
		True for success, else sting containing error details
--]]
--local function load_mach_config_file()
--	mach_lib.update_mach_lua_log("Getting values from MACH config file.")
--	local config_file = loadfile("data/WALI/mach_config.lua")
--	if type(config_file) == "nil" then
--		mach_lib.update_mach_lua_log(config_file.." failed to load, does not exist")
--		return false
--	end
--	setfenv(config_file, getfenv())
--	config_file()
--	mach_lib.update_mach_lua_log("Loaded config successfully.")
--	return true
--end


function show_mach_enabled_mods_text_in_advice_box()
	mach_lib.update_mach_lua_log("Showing MACH enabled mods advice text in advice box.")

	local mach_features_str = "Machiavelli's Enabled Mods:\n\n"
	for feat_count = 1, #__mach_features_enabled__ do
		mach_lib.update_mach_lua_log(string.format('Showing enabled mod in advice box: "%s"', __mach_features_enabled__[feat_count]))
		mach_features_str  = mach_features_str..'* '..tostring(__mach_features_enabled__[feat_count])..'\n\n'
	end
	effect.advice(mach_features_str)
	effect.suspend_contextual_advice(false)
	__mach_enabled_mods_msg_box_displayed__ = true
	mach_lib.update_mach_lua_log("Finished showing MACH enabled mods advice text in advice box.")
end


scripting.AddEventCallBack("CampaignArmiesMerge", mach_lib.on_campaign_armies_merge)
scripting.AddEventCallBack("CharacterCreated", mach_lib.on_character_created)
scripting.AddEventCallBack("CharacterSelected", mach_lib.on_character_selected)
scripting.AddEventCallBack("ComponentLClickUp", mach_lib.on_component_left_click_up)
scripting.AddEventCallBack("FactionTurnEnd", mach_lib.on_faction_turn_end)
scripting.AddEventCallBack("FactionTurnStart", mach_lib.on_faction_turn_start)
scripting.AddEventCallBack("LoadingGame", mach_lib.on_loading_game)
scripting.AddEventCallBack("PanelClosedCampaign", mach_lib.on_panel_closed_campaign)
scripting.AddEventCallBack("PanelOpenedCampaign", mach_lib.on_panel_opened_campaign)
scripting.AddEventCallBack("RegionRebels", mach_lib.on_region_rebels)
scripting.AddEventCallBack("SavingGame", mach_lib.on_saving_game)
scripting.AddEventCallBack("TimeTrigger", mach_lib.on_time_trigger)
scripting.AddEventCallBack("UICreated", mach_lib.on_ui_created)
