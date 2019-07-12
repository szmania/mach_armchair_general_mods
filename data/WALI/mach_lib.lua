module(..., package.seeall)

--utils = require("Utilities")
--huds = utils.Require("Huds")
--WALI = require "WALI/WALI"
mach = require "WALI/mach"
mach_classes = require "WALI/mach_classes"
mach_config = require "WALI/mach_config"
mach_data = require "WALI/mach_data"

--require("WALI/external_libs/json")


--ti_lib = require "WALI/TI_lib"

scripting = require "EpisodicScripting"


__character_names_file_path__ =	"data/WALI/Misc/character_names.txt"
__current_year__ = nil
__current_turn__ = nil
__current_season_string__ = nil
__current_faction_turn_id__ = nil
__loading_game__ = false
__mach_log_func_name__ = ""
__mach_log_file__ = "data/WALI/Logs/mach_lua.log"
__mach_save_game_id__ = nil
__player_faction_id__ = nil
__saving_game__ = false
__unit_scale_factor__ = nil
__wali_m_root__ = nil --the UI root
__wali_is_on_campaign_map__ = false
__wali_is_first_click_on_army__ = false
__wali_army_is_selected__ = false
__wali_previously_selected_character_pointer__ = nil



function concat_tables(t1, t2)
	update_mach_lua_log('Concatenating two tables.')
	local t1_num = get_num_of_elements_in_table(t1)
	local t2_num = get_num_of_elements_in_table(t2)
	update_mach_lua_log(string.format('Table #1 has "%s" elements, table #2 has "%s" elements.', t1_num, t2_num))
	local concatenated_table = copy_table(t1)

	function _concat_tables(t1, t2)
		for k,v in pairs(t2) do
			if #t2 > 0 then
--				for k,v in pairs(t2) do
				table.insert(t1, v)
--				end
			elseif type(v) == "table" then
				if type(t1[k] or false) == "table" then
					if #t1[k] > 0 then
--						for k,v in pairs(t2) do
						table.insert(t1, v)
--						end
					else
						_concat_tables(t1[k] or {}, t2[k] or {})
					end
				else
					t1[k] = v
				end
			else
				t1[k] = v
			end
		end
		return t1
	end

--	local function _concat_tables(t1, t2, t3)
--		for t2_key, t2_value in pairs(t1) do
--			update_mach_lua_log(t2_key)
--			update_mach_lua_log(t2_value)
--		end
--		for t2_key, t2_value in pairs(t2) do
--			update_mach_lua_log(t2_key)
--			update_mach_lua_log(t2_value)
--			if t1[t2_key] == nil then
--				update_mach_lua_log('im here')
--				t3[t2_key] = t2[t2_key]
--			elseif t1[t2_key] ~= t2[t2_key] then
--				update_mach_lua_log('im here2')
--				if type(t1[t2_key]) == "table" and type(t2[t2_key]) == "table" then
--					if not t3[t2_key] then
--						t3[t2_key] = {}
--					end
--					t3[t2_key] = _concat_tables(t1[t2_key], t2[t2_key], t3[t2_key])
--				end
--			end
--		end
--		return t3
--	end

--	for t2_key, t2_value in pairs(concatenated_table) do
--		update_mach_lua_log(t2_key)
--		update_mach_lua_log(t2_value)
--	end
--	update_mach_lua_log('crap')
	concatenated_table = _concat_tables(concatenated_table, t2)
--	update_mach_lua_log('tick')
--	for t2_key, t2_value in pairs(concatenated_table) do
--		update_mach_lua_log(t2_key)
--		update_mach_lua_log(t2_value)
--	end
	local concatenated_table_num = get_num_of_elements_in_table(concatenated_table)
	update_mach_lua_log(string.format('Finished concatenating tables with result of %s elements.', concatenated_table_num))
	return concatenated_table
end


function convert_array_to_set(array)
	update_mach_lua_log("Converting array to set.")
	local set = {}
	for idx = 1, #array do
		set[array[idx]] = true
	end
	update_mach_lua_log("Finished converting array to set.")
	return set
end


function convert_str_to_title_case(str)
	update_mach_lua_log(string.format('Converting string to title case: "%s"', str))
	local title_case_str = ''
	for word in string.gfind(str, "%S+") do
		local first = string.sub(word,1,1)
		title_case_str = (title_case_str .. string.upper(first) ..
				string.lower(string.sub(word,2)))
	end
	update_mach_lua_log(string.format('Finished converting string to title case: "%s"', title_case_str))
	return title_case_str
end


function copy_table(tbl)
	update_mach_lua_log("Copying table.")

--	local function _deep_copy_tbl(orig)
--		local orig_type = type(orig)
--		local copy
--		if orig_type == 'table' then
--			copy = {}
--			for orig_key, orig_value in next, orig, nil do
--				copy[_deep_copy_tbl(orig_key)] = _deep_copy_tbl(orig_value)
--			end
--			setmetatable(copy, _deep_copy_tbl(getmetatable(orig)))
--		else -- number, string, boolean, etc
--			copy = orig
--		end
--		return copy
--	end
--	local copied_tbl = _deep_copy_tbl(tbl)
--	update_mach_lua_log("Finished copying table.")
--	return copied_tbl
	local lookup_table = {}
	local function _copy(tbl)
		if type(tbl) ~= "table" then
			return tbl
		elseif lookup_table[tbl] then
			return lookup_table[tbl]
		end
		local new_table = {}
		lookup_table[tbl] = new_table
		for index, value in pairs(tbl) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(tbl))
	end
	local copied_tbl =  _copy(tbl)
	update_mach_lua_log("Finished copying table.")
	return copied_tbl
end


--Creates a new MACH log in the logging directory
-- Creates MACH log
function create_mach_lua_log()
	local error_log = io.open(__mach_log_file__,"w")
	local date_and_time = os.date("%H:%M.%S")
    error_log:write("Log Created: "..date_and_time)
    error_log:close()
end


function export_string(s)
	return string.format("%q", s)
end


-- Find region_capital_distance from (x1, y1) to (x2, y2)
-- @param x1: x1 coordinate
-- @param y1: y1 coordinate
-- @param x2: x2 coordinate
-- @param y2: y2 coordinate
-- @return region_capital_distance as double
function find_distance( x1, y1, x2, y2)
--	update_mach_lua_log(string.format("Finding distance between (%s, %s) and (%s, %s)", x1, y1, x2, y2))
	local dx = x1 - x2
    local dy = y1 - y2
    local distance = math.sqrt( dx * dx + dy * dy )
--	update_mach_lua_log('Distance is: '..distance)
	return distance
end


function file_exists(file_path)
	update_mach_lua_log(string.format('Checking if file exists: "%s"', file_path))
	local f=io.open(file_path,"r")
	if f~=nil then
		io.close(f)
		update_mach_lua_log(string.format('File does exist: "%s"', file_path))
		return true
	end
	update_mach_lua_log(string.format('File does NOT exist: "%s"', file_path))
	return false
end


function get_all_factions_military_forces()
	update_mach_lua_log("Getting all factions military forces.")
	local all_factions_military_forces = {}
	local total_military_forces = 0
	local faction_id_list = mach_data.__faction_id_list__
	for _, faction_id in pairs(faction_id_list) do
		local faction_military_forces = get_faction_military_forces(faction_id)
		total_military_forces = total_military_forces + get_num_of_elements_in_table(faction_military_forces)
		all_factions_military_forces[faction_id] = faction_military_forces
	end
	update_mach_lua_log('Finished getting all factions military forces. Total military forces: '..tostring(total_military_forces))
	return all_factions_military_forces
end


function get_army_from_character_context(character_context)
	update_mach_lua_log("Getting army from character context.")
	local army = nil
	if is_character_general(character_context) or is_character_colonel(character_context) then
		local character_context_address = nil
		local character_context_pointer = nil
		character_context_address, character_context_pointer = get_character_address_and_pointer_from_character_selected_context(character_context)
		local faction_id = get_faction_id_from_context(character_context, "CharacterSelected")
		local faction_army_forces = get_faction_army_forces(faction_id)
		for faction_army_force_key, army in pairs(faction_army_forces) do
			if army.address == character_context_address then
				update_mach_lua_log(string.format('Army gotten from character context. Army is under command of "%s"',
					army.commander_name))
				return army
			end

		end
	else
		update_mach_lua_log("Character is NOT General or colonel. Cannot lead an army!")
		return army
	end
	update_mach_lua_log("ERROR: Character's army could not be found!")
	return army
end


function get_army_in_settlement_address(settlement_address)
	update_mach_lua_log(string.format('Getting army in settlement address: "%s"', tostring(settlement_address)))
	local faction_army_in_settlement
	local settlement_id = get_settlement_id_from_settlement_address(settlement_address)
	local faction_id = get_faction_id_from_settlement_id(settlement_id)
	local faction_army_forces = get_faction_army_forces(faction_id)
	for faction_army_forces_key, faction_army_force in pairs(faction_army_forces) do
		if settlement_id == faction_army_force.settlement_in_id then
			faction_army_in_settlement = faction_army_force
			break
		end
	end
	update_mach_lua_log(string.format('Finished getting army in settlement address. Army commander: "%s"', faction_army_in_settlement.commander_name))
	return faction_army_in_settlement
end

-- Determine number of artillery an artillery unit has according to its number of men
-- @param men: number of men as integer
-- @return: number of artillery pieces as integer
function get_artillery_num_from_men_count(men)
	-- FIND REMAINDER EQUATION: a - math.floor(a/b)*b
	men = tonumber(men)
	if(men > 0) and (men < 7) then
		return 1
	elseif(men == 7) then
		return 2
	end
  
  
	--determine for 5 and remainder
	local remainder = 0
	remainder = men - (math.floor(men / 5) * 5)
		
	if(remainder == 0) then
		return men / 5
	elseif(remainder == 1) then
		return math.floor(men / 5)
	elseif(remainder > 1) then
		--if math.floor(men / 5) < math.floor(men / 4) then
		--	return math.floor(men / 5)
		--else
		--	return math.floor(men / 4)
		--end
		return math.floor((men / 5)) + 1

	end
end


function get_battle_faction_names_str(faction_ids)
	update_mach_lua_log('Getting faction names str from faction ids list.')
	local faction_names_str = ''
	for faction_id_idx = 1, #faction_ids do
		local faction_id = faction_ids[faction_id_idx]
		if faction_id_idx == 1 then
			faction_names_str = get_faction_screen_name_from_faction_id(faction_id)
		else
			faction_names_str = faction_names_str..", "..get_faction_screen_name_from_faction_id(faction_id)
		end
	end
	if faction_names_str == '' then
		faction_names_str = 'Rebels'
	end
	update_mach_lua_log(string.format('Finished getting faction names str from faction ids list. Faction names str: "%s"', faction_names_str))
	return faction_names_str
end


function get_battles_with_character_name(character_name, faction_id)
	update_mach_lua_log(string.format('Getting battles with character name "%s" of faction "%s".', character_name, faction_id))
	local battles_list = {}
	for battle_idx, battle in pairs(mach_data.__battles_list__) do
--		if is_value_in_table(character_name, battle.winner_commander_names) or is_value_in_table(character_name, battle.loser_commander_names) then
--			battles_list[#battles_list+1] = battle
--		end
		local pre_battle_faction_units_or_ships = {}
		if not battle.is_naval_battle then
			if battle.pre_battle_units_list[faction_id] then
				pre_battle_faction_units_or_ships = battle.pre_battle_units_list[faction_id]
			end
		else
			if battle.pre_battle_ships_list[faction_id] then
				pre_battle_faction_units_or_ships = battle.pre_battle_ships_list[faction_id]
			end
		end
		for military_unit_idx, military_unit in pairs(pre_battle_faction_units_or_ships) do
--			output_table_to_mach_log(military_unit, 1)
			if military_unit.commander_name == character_name then
				update_mach_lua_log(military_unit.commander_name)
				battles_list[#battles_list+1] = battle
			end
		end

	end
	update_mach_lua_log(string.format('Finished getting battles with character name. Total battles "%s"', #battles_list))
	return battles_list
end


function get_battles_with_unit_id(unit_id, faction_id)
	update_mach_lua_log(string.format('Getting battles with unit id "%s" of faction "%s".', unit_id, faction_id))
	local battles_list = {}
	for battle_idx, battle in pairs(mach_data.__battles_list__) do
		local pre_battle_faction_units_or_ships = {}
		if not battle.is_naval_battle then
			if battle.pre_battle_units_list[faction_id] then
				pre_battle_faction_units_or_ships = battle.pre_battle_units_list[faction_id]
			end
		else
			if battle.pre_battle_ships_list[faction_id] then
				pre_battle_faction_units_or_ships = battle.pre_battle_ships_list[faction_id]
			end
		end
		for military_unit_idx, military_unit in pairs(pre_battle_faction_units_or_ships) do
			if military_unit.unit_id == unit_id then
				battles_list[#battles_list+1] = battle
			end
		end
	end
	update_mach_lua_log(string.format('Finished getting battles with unit id. Total battles "%s"', #battles_list))
	return battles_list
end


-- Build settlement besieged list list
-- @return: settlement besieged list
function get_besieged_settlements()
	update_mach_lua_log("Getting besieged settlements.")

	local besieged_settlements = {}
	local region_id = false
	local distance = false
	local army_besieged_settlement = false

	local faction_id_list = mach_data.__faction_id_list__
	for _, faction_id in pairs(faction_id_list) do
		local enemy_faction_ids = get_faction_ids_at_war_with_faction(faction_id)
--		local diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(faction_id)
--		if diplomacy_details then
		for _, enemy_faction_id in pairs(enemy_faction_ids) do
			local forces_list = CampaignUI.RetrieveFactionMilitaryForceLists(enemy_faction_id, true)
			for forces_list_idx = 1, #forces_list do
				local army = forces_list[forces_list_idx]
				local faction_regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_id)
				for faction_region_idx = 1, #faction_regions do
					region_id = CampaignUI.RegionKeyFromAddress(faction_regions[faction_region_idx].Address)
					distance = find_distance(army.PosX, army.PosY, mach_data.region_capital_coord_list[region_id][1], mach_data.region_capital_coord_list[region_id][2])
					if (distance < 1.5 and distance > -1.5) and distance ~= nil then
						update_mach_lua_log(string.format('Settlement is besieged: %s', region_id))
						army_besieged_settlement = true
						besieged_settlements[#besieged_settlements + 1] = region_id
					end
				end
			end
		end
--		end
	end
	update_mach_lua_log("Finished getting besieged settlements.")
	return besieged_settlements
end


function get_character_address_and_pointer_from_character_selected_context(context)
	update_mach_lua_log("Getting character memory address and pointer from character selected context.")
	local entity_type_selected = CampaignUI.EntityTypeSelected()
	local character_address = nil
    local character_pointer = nil
	if conditions.CharacterType("admiral", context) or conditions.CharacterType("General", context) then
		update_mach_lua_log("Character is a admiral or General. Returning character memory address and pointer.")
		local char_details = CampaignUI.InitialiseCharacterDetails(entity_type_selected.Entity)
		character_address, character_pointer = entity_type_selected.Entity
	elseif conditions.CharacterType("captain", context) or conditions.CharacterType("colonel", context) then
		update_mach_lua_log("Character is a captain or colonel. Returning memory address and pointer.")
		local unit_details = CampaignUI.InitialiseUnitDetails(entity_type_selected.Entity)
		character_address, character_pointer = unit_details.CharacterPtr
	end
	update_mach_lua_log("Finished getting character memory address and pointer from character selected context.")
	return character_address, character_pointer
end


function get_character_culture_from_character_context(character_context)
	update_mach_lua_log('Getting character culture from character context.')

	local character_culture = nil
	if conditions.CharacterCultureType('european', character_context) then
		character_culture = 'european'
	elseif conditions.CharacterCultureType('indian', character_context) then
			character_culture = 'indian'
	elseif conditions.CharacterCultureType('middle_east', character_context) then
		character_culture = 'middle_east'
	elseif conditions.CharacterCultureType('tribal', character_context) then
		character_culture = 'tribal'
	end
	update_mach_lua_log(string.format('Finished getting character culture from character context. Character culture: "%s"', character_culture))
	return character_culture
end


function get_character_details_from_entity_type_selected(entity_type_selected)
	update_mach_lua_log('Getting character details from address.')
	local character_details = nil
	if entity_type_selected.Character then
		update_mach_lua_log('testers2')
		character_details = CampaignUI.InitialiseCharacterDetails(entity_type_selected.Entity)
	elseif entity_type_selected.Unit then
		update_mach_lua_log('testers')
		local unit_details = CampaignUI.InitialiseUnitDetails(entity_type_selected.Entity)
		character_details =  CampaignUI.InitialiseCharacterDetails(unit_details.CharacterPtr)
	end
	if not character_details then
		update_mach_lua_log(string.format('Error, unable to get character details of character!'))
	end
	update_mach_lua_log("Finished getting character details from address.")
	return character_details
end


function get_character_details_from_character_context(context, context_type)
	update_mach_lua_log('Getting character details for context type: "'..tostring(context_type)..'"')
	local character_details = nil
	if context_type == "CharacterSelected" then
		local entity_type_selected = CampaignUI.EntityTypeSelected()
		if conditions.CharacterType("admiral", context) or conditions.CharacterType("General", context) then
			update_mach_lua_log("Character is a admiral or General. Returning character details.")
			character_details = CampaignUI.InitialiseCharacterDetails(entity_type_selected.Entity)
		elseif conditions.CharacterType("captain", context) or conditions.CharacterType("colonel", context) then
			update_mach_lua_log("Character is a captain or colonel. Returning character details.")
			local unitDetails = CampaignUI.InitialiseUnitDetails(entity_type_selected.Entity)
			character_details =  CampaignUI.InitialiseCharacterDetails(unitDetails.CharacterPtr)
		end
	elseif context_type == "CharacterCompletedBattle" or context_type == 'CharacterCreated' then
		local character_full_name = get_character_full_name_from_character_context(context)
		local faction_id = get_faction_id_from_context(context, "CharacterCompletedBattle")
		local faction_military_forces = get_faction_military_forces(faction_id)
		for faction_military_force_key, faction_military_force in pairs(faction_military_forces) do
			local character_pointer = faction_military_force.address
			local character_details_test = CampaignUI.InitialiseCharacterDetails(character_pointer)
			local formatted_character_full_name = character_full_name:gsub("[’']", "")
--			update_mach_lua_log('Formatted character full name: '..formatted_character_full_name)
			local formatted_character_details_name = character_details_test.Name
			formatted_character_details_name = formatted_character_details_name:gsub("[’']", "")
--			update_mach_lua_log('Formatted character details name: '..formatted_character_details_name)
			if formatted_character_details_name == formatted_character_full_name then
				update_mach_lua_log(string.format('Character details found: "%s" == "%s"', formatted_character_details_name, formatted_character_full_name))
				character_details = character_details_test
				break
			end
		end
		if not character_details then
			update_mach_lua_log(string.format('Error, unable to get character details of character "%s"!', character_full_name))
		end
	end
	update_mach_lua_log("Finished getting character details.")
	return character_details
end


function get_character_full_name_from_character_context(character_context)
	update_mach_lua_log('Getting character full name from character context')
	local character_forename = nil
	local character_surname = nil
	for character_names_key, character_names_value in pairs(mach_data.__character_names_list__) do
		if conditions.CharacterForename(character_names_key, character_context) then
			character_forename = character_names_value
		end
		if conditions.CharacterSurname(character_names_key, character_context) then
			character_surname = character_names_value
		end
		if character_forename and character_surname then
			break
		end
	end
	local character_full_name = character_forename.." "..character_surname
	update_mach_lua_log(string.format('Finished getting character full name from character context. Character full name: %s', character_full_name))
	return character_full_name
end


-- Build character names localisation list
-- @return: character localisation names list
function get_character_names_list()
    update_mach_lua_log("Building character names list.")

    local character_names_list = {}
    local file = io.open(__character_names_file_path__, "r")
    while true do
		local line = file:read("*line")
        if line == nil then
            break
		end
		local name_key = split_str(line, ":")[1]
		name_key = name_key:gsub("\"", "")
		local name = split_str(line, ":")[2]
        name = name:gsub("\"", "")
        character_names_list[name_key] = name
	end
    file:close()
    update_mach_lua_log("Finished building character names list list.")
    return character_names_list
end


function get_character_region_from_character_context(character_context)
	update_mach_lua_log('Getting character region from character context.')
	local character_region = nil
	for region_id_idx, region_id_value in pairs(mach_data.__region_id_list__) do
		if conditions.CharacterInRegion(region_id_value, character_context) then
			character_region = region_id_value
			break
		end
	end
	update_mach_lua_log(string.format('Finished getting character region from character context. Character region: %s', character_region))
	return character_region
end


function get_character_type_from_character_context(character_context)
	update_mach_lua_log('Getting character type from character context')
	local character_type = nil
	for character_type_idx, character_type_value in pairs(mach_data.character_types) do
		if conditions.CharacterType(character_type_value, character_context) then
			character_type = convert_str_to_title_case(character_type_value)
			break
		end
	end
	update_mach_lua_log(string.format('Finished getting character type from character context. Character type: "%s"', character_type))
	return character_type
end


function get_currently_loaded_save_game()
	update_mach_lua_log('Getting currently loaded save game.')
	local currently_loaded_game_save_game
	local currently_loaded_game_info = CampaignUI.GetCurrentGameInfo()
	output_table_to_mach_log(currently_loaded_game_info,1)
	update_mach_lua_log('tea')

	local extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
	local save_game_list = CampaignUI.EnumerateCampaignSaves(path, "*"..extension)
	for save_game_idx, save_game in pairs(save_game_list) do
		local extended_save_game_info = CampaignUI.GetExtendedSaveGameInfo(save_game.Path)
		update_mach_lua_log('pie')

		output_table_to_mach_log(extended_save_game_info,1)
		update_mach_lua_log('cheech')
		output_table_to_mach_log(save_game,1)
		update_mach_lua_log('cherry')

		if currently_loaded_game_info == extended_save_game_info then
			update_mach_lua_log('crapola')
			currently_loaded_game_save_game = save_game
			break
		end
	end
	update_mach_lua_log('Finished getting current loaded game.')
	return currently_loaded_game_save_game
end


function get_faction_army_forces(faction_id)
    update_mach_lua_log("Getting faction army forces for faction_id: "..tostring(faction_id))
    local faction_forces_list = CampaignUI.RetrieveFactionMilitaryForceLists(faction_id, true) or {}
	local faction_army_forces = {}
	for faction_forces_idx = 1, #faction_forces_list do
		local faction_army_force = mach_classes.Army:new(faction_forces_list[faction_forces_idx], faction_id)
		faction_army_forces[faction_army_force.address] = faction_army_force
	end
	update_mach_lua_log('Finished getting army forces for faction_id "'..tostring(faction_id)..'". Total army forces: '..tostring(get_num_of_elements_in_table(faction_army_forces)))
	return faction_army_forces
end


function get_faction_id_from_settlement_id(settlement_id)
	update_mach_lua_log(string.format('Getting faction id from settlement id "%s".', settlement_id))
	local faction_id
	local region_id = mach_data.settlement_to_region_list[settlement_id]
	for faction_id_idx, faction_id_value in pairs(mach_data.__faction_id_list__) do
		local faction_regions = get_faction_regions(faction_id_value)
		for faction_region_idx, faction_region_value in pairs(faction_regions) do
			local faction_region = faction_regions[faction_region_idx]
			if region_id == faction_region.region_id then
				faction_id = faction_region.faction_id
				break
			end
		end
	end
	update_mach_lua_log(string.format('Finished getting faction id from settlement id. Faction id is "%s".', faction_id))
	return faction_id
end


function get_faction_id_from_character_address(character_address)
	update_mach_lua_log(string.format('Getting faction id from character address: "%s"', tostring(character_address)))
	local faction_id
	for faction_id_idx, faction_id_value in pairs(mach_data.__faction_id_list__) do
		local faction_land_forces_list = CampaignUI.RetrieveFactionMilitaryForceLists(faction_id_value, true) or {}
		for faction_land_forces_idx = 1, #faction_land_forces_list do
			local faction_land_force = faction_land_forces_list[faction_land_forces_idx]
			if character_address == faction_land_force.Address then
				faction_id = faction_id_value
				break
			end
		end
		if faction_id then
			break
		end
		local faction_naval_forces_list = CampaignUI.RetrieveFactionMilitaryForceLists(faction_id_value, false) or {}
		for faction_naval_forces_idx = 1, #faction_naval_forces_list do
			local faction_naval_force = faction_naval_forces_list[faction_naval_forces_idx]
			if character_address == faction_naval_force.Address then
				faction_id = faction_id_value
				break
			end
		end
		if faction_id then
			break
		end
	end
	update_mach_lua_log(string.format('Finished getting faction id from character address. Faction id: "%s"', tostring(faction_id)))
    return faction_id
end


function get_faction_id_list()
    update_mach_lua_log('Getting faction id list.')
	local faction_id_list = copy_table(mach_data.faction_id_list)
    local faction_id_list_for_diplomacy = CampaignUI.RetrieveFactionListForDiplomacy()
	for faction_id_list_for_diplomacy_key, faction_id_list_for_diplomacy_value in pairs(faction_id_list_for_diplomacy) do
		local found_diplomacy_faction = false
		for faction_id_list_idx = 1, #faction_id_list do
			local faction_id = faction_id_list[faction_id_list_idx]
			if faction_id_list_for_diplomacy_key == faction_id then
				found_diplomacy_faction = true
				break
			end
		end
		if not found_diplomacy_faction then
			faction_id_list[#faction_id_list+1] = faction_id_list_for_diplomacy_key
		end
	end
    update_mach_lua_log('Finished getting faction id list.')
    return faction_id_list
end


function get_faction_id_from_context(context, context_type)
    update_mach_lua_log('Getting faction id from context: "'..tostring(context_type)..'"')
    local current_faction_id = nil
    local faction_id_list = mach_data.__faction_id_list__
    for _, faction_id in pairs(faction_id_list) do
        if context_type == 'CampaignSettlementAttacked' or context_type == "CharacterCompletedBattle" or context_type == "CharacterCreated" or context_type == "CharacterSelected" or context_type == "CharacterTurnEnd" or context_type == "CharacterTurnStart" then
            if conditions.CharacterFactionName(faction_id, context) then
                current_faction_id = faction_id
                break
            end
        elseif context_type == "FactionTurnStart" or context_type == "FactionTurnEnd" then
            if conditions.FactionName(faction_id, context) then
                current_faction_id = faction_id
                break
			end
		elseif context_type == "UICreated" then
			current_faction_id = CampaignUI.PlayerFactionId()
			break
		end
    end
    update_mach_lua_log(string.format('Finished getting faction id from context "%s". Faction id for context is: %s', context_type, current_faction_id))
    return current_faction_id
end


function get_faction_ids_at_war_with_faction(faction_id)
	update_mach_lua_log(string.format('Getting faction ids at war with faction "%s".', faction_id))
	local enemy_faction_id_list = {}
	if not string.find(faction_id, 'rebels') then
		enemy_faction_id_list = copy_table(mach_data.faction_id_list_pirates_and_rebels)
		local diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(faction_id)
		if diplomacy_details then
			for diplomacy_at_war_faction_id, diplomacy_at_war_faction_value in pairs(diplomacy_details.AtWar) do
				local found_diplomacy_at_war_faction = false
				for enemy_faction_id_list_idx = 1, #enemy_faction_id_list do
					local enemy_faction_id = enemy_faction_id_list[enemy_faction_id_list_idx]
					if diplomacy_at_war_faction_id == enemy_faction_id then
						found_diplomacy_at_war_faction = true
						break
					end
				end
				if not found_diplomacy_at_war_faction then
					enemy_faction_id_list[#enemy_faction_id_list+1] = diplomacy_at_war_faction_id
				end
			end
		end
	else
		enemy_faction_id_list = copy_table(mach_data.__faction_id_list__)
	end
	for enemy_faction_id_list_idx = 1, #enemy_faction_id_list do
		local enemy_faction_id = enemy_faction_id_list[enemy_faction_id_list_idx]
		if enemy_faction_id == faction_id then
			table.remove(enemy_faction_id_list, enemy_faction_id_list_idx)
		end
	end
	update_mach_lua_log(string.format('Finished getting faction ids at war with faction "%s".', faction_id))
	return enemy_faction_id_list
end


function get_faction_military_forces(faction_id)
	update_mach_lua_log("Getting military forces for faction_id: "..tostring(faction_id))
	local faction_military_forces = concat_tables(get_faction_army_forces(faction_id), get_faction_naval_forces(faction_id))
	update_mach_lua_log('Finished getting military forces for faction_id "'..tostring(faction_id)..'". Total military forces: '..tostring(get_num_of_elements_in_table(faction_military_forces)))
	return faction_military_forces
end


function get_faction_protectorate_and_ally_military_forces(faction_id)
	update_mach_lua_log("Getting protectorate and ally military forces for faction_id: "..tostring(faction_id))
	local protectorate_and_ally_factions_military_forces = {}
	local total_protectorate_and_ally_military_forces = 0
	local diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(faction_id)
	local protectorates_and_allies_faction_list = concat_tables(diplomacy_details.Protectorates, diplomacy_details.ProtectorOf)
	protectorates_and_allies_faction_list = concat_tables(protectorates_and_allies_faction_list, diplomacy_details.Allies)
	for protectorate_and_ally_faction_id, protectorates_and_allies_faction_list_value in pairs(protectorates_and_allies_faction_list) do
		local protectorate_and_ally_faction_military_forces = get_faction_military_forces(protectorate_and_ally_faction_id)
		protectorate_and_ally_factions_military_forces[protectorate_and_ally_faction_id] = protectorate_and_ally_faction_military_forces
		total_protectorate_and_ally_military_forces = total_protectorate_and_ally_military_forces + get_num_of_elements_in_table(protectorate_and_ally_faction_military_forces)
	end
	update_mach_lua_log('Finished getting protectorate and ally military forces for faction_id "'..tostring(faction_id)..'". Total protectorate and ally military forces: '..tostring(total_protectorate_and_ally_military_forces))
	return protectorate_and_ally_factions_military_forces
end


function get_faction_enemy_military_forces(faction_id)
	update_mach_lua_log("Getting enemy military forces for faction_id: "..tostring(faction_id))
	local enemy_factions_military_forces = {}
	local total_enemy_military_forces = 0
--	local diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(faction_id)
	local enemy_faction_list = get_faction_ids_at_war_with_faction(faction_id)
--	enemy_faction_list['pirates'] = {}
	for _, enemy_faction_id in pairs(enemy_faction_list) do
		local enemy_faction_military_forces = get_faction_military_forces(enemy_faction_id)
		enemy_factions_military_forces[enemy_faction_id] = enemy_faction_military_forces
		total_enemy_military_forces = total_enemy_military_forces + get_num_of_elements_in_table(enemy_faction_military_forces)
	end
	update_mach_lua_log('Finished getting enemy military forces for faction_id "'..tostring(faction_id)..'". Total enemy military forces: '..tostring(total_enemy_military_forces))
	return enemy_factions_military_forces
end


function get_faction_naval_forces(faction_key)
	update_mach_lua_log("Getting naval forces for faction_key: "..tostring(faction_key))
	local faction_forces_list = CampaignUI.RetrieveFactionMilitaryForceLists(faction_key, false) or {}
	local faction_naval_forces = {}
	for faction_forces_idx = 1, #faction_forces_list do
		local faction_naval_force = mach_classes.Navy:new(faction_forces_list[faction_forces_idx], faction_key)
		faction_naval_forces[faction_naval_force.address] = faction_naval_force
	end
	update_mach_lua_log('Finished getting naval forces for faction_key "'..tostring(faction_key)..'". Total naval forces: '..tostring(get_num_of_elements_in_table(faction_naval_forces)))
	return faction_naval_forces
end


function get_faction_num_of_ships(faction_id)
	update_mach_lua_log("Getting faction number of ships: "..tostring(faction_id))
	local faction_naval_forces = get_faction_naval_forces(faction_id)
	local faction_num_of_ships = 0
	for k, v in pairs(faction_naval_forces) do
		local faction_naval_force = faction_naval_forces[k]
		faction_num_of_ships = faction_num_of_ships + tonumber(faction_naval_force.num_of_units)
	end
	update_mach_lua_log('Faction "'..tostring(faction_id)..'" has '..tostring(faction_num_of_ships)..' number of ships.')
	return faction_num_of_ships
end


function get_faction_num_of_soldiers(faction_id)
	update_mach_lua_log("Getting faction number of soldiers: "..tostring(faction_id))
	local faction_army_forces = get_faction_army_forces(faction_id)
	local faction_num_of_soldiers = 0
	for k, v in pairs(faction_army_forces) do
		local faction_army_force = faction_army_forces[k]
		faction_num_of_soldiers = faction_num_of_soldiers + tonumber(faction_army_force.num_of_soldiers)
	end
	update_mach_lua_log('Faction "'..tostring(faction_id)..'" has '..tostring(faction_num_of_soldiers)..' number of soldiers.')
	update_mach_lua_log("Finished getting faction number of soldiers: "..tostring(faction_id))
	return faction_num_of_soldiers
end


function get_faction_and_protectorates_regions(faction_key)
	update_mach_lua_log("Getting faction_key and its protectorates regions for faction_key: "..tostring(faction_key))
	local faction_and_protectorates_regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_key)
	update_mach_lua_log("Finished getting faction_key and its protectorates regions.")
	return faction_and_protectorates_regions
end


function get_faction_regions(faction_key)
	update_mach_lua_log("Getting regions for faction_key: "..tostring(faction_key))
	local faction_regions = {}
	local faction_and_protectorates_regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_key) or {}
	for k, v in pairs(faction_and_protectorates_regions) do
		if faction_and_protectorates_regions[k].OwnedByProtectorate == false then
			local region = mach_classes.Region:new(faction_and_protectorates_regions[k], faction_key)
			faction_regions[k] = region
		end
	end
	update_mach_lua_log("Finished getting regions for faction_key. Number of faction regions: "..tostring(#faction_regions))
	return faction_regions
end


function get_faction_screen_name_from_faction_id(faction_id)
	update_mach_lua_log("Getting faction screen name for faction id: "..tostring(faction_id))
	local faction_screen_name = nil
	if string.find(faction_id, 'rebels') then
		faction_screen_name = 'Rebels'
	else
		local faction_screen_name_key = string.format('factions_screen_name_%s',  tostring(faction_id))
		faction_screen_name = CampaignUI.LocalisationString(faction_screen_name_key, true)
	end
	update_mach_lua_log("Faction screen name is: "..tostring(faction_screen_name))
	return faction_screen_name
end


function get_friendly_regions(faction_key)
	update_mach_lua_log("Getting friendly regions for faction_key: "..tostring(faction_key))
--	local friendly_regions = get_faction_and_protectorates_regions(faction_key)

	local friendly_regions = {}
--	local i = #friendly_regions
	local faction_regions = get_faction_regions(faction_key)
	for kk, vv in pairs(faction_regions) do
		local region = faction_regions[kk]
        friendly_regions[#friendly_regions+1] = region
	end

	local faction_diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(faction_key)
--	output_obj_to_mach_log(faction_regions, 1)

	update_mach_lua_log("Getting regions of Protectorates.")
	local protectorates_regions = {}
	for k, v in pairs(faction_diplomacy_details.Protectorates) do
		local faction_regions = get_faction_regions(v.Label)
		for kk, vv in pairs(faction_regions) do
			local region = faction_regions[kk]
			friendly_regions[#friendly_regions+1] = region
		end
	end

	update_mach_lua_log("Getting regions of ProtectorOf.")
	local protector_of_regions = {}
	for k, v in pairs(faction_diplomacy_details.ProtectorOf) do
		local faction_regions = get_faction_regions(v.Label)
		for kk, vv in pairs(faction_regions) do
			local region = faction_regions[kk]
			friendly_regions[#friendly_regions+1] = region
		end
	end

	update_mach_lua_log("Getting regions of Allies.")
	local ally_regions = {}
	for k, v in pairs(faction_diplomacy_details.Allies) do
		local faction_regions = get_faction_regions(v.Label)
		for kk, vv in pairs(faction_regions) do
			local region = faction_regions[kk]
			friendly_regions[#friendly_regions+1] = region
		end
	end
	update_mach_lua_log("Finished getting friendly regions.")
	return friendly_regions
end


function get_intersection_point_of_two_lines(line_slope_1, y_intercept_1, x2, line_slope_2, y_intercept_2)
	update_mach_lua_log("Getting intersection point of two lines.")
	local intersection_pos_x = (((line_slope_2 * x2) + y_intercept_2) - y_intercept_1) / line_slope_1
	local intersection_pos_y = (line_slope_2 * intersection_pos_x) + y_intercept_2
	return intersection_pos_x, intersection_pos_y
end


function get_latest_save_game()
	update_mach_lua_log("Getting latest save game.")
	local extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
	local save_game_list = CampaignUI.EnumerateCampaignSaves(path, "*"..extension)
	local latest_save_game
	local latest_save_game_date = 0
	for save_game_idx, save_game in pairs(save_game_list) do
--		update_mach_lua_log(save_game.FileName)
		if tonumber(save_game.Date) > latest_save_game_date then
--			update_mach_lua_log(save_game.FileName)
--			update_mach_lua_log(string.format('date: %s', save_game.Date))
			latest_save_game = save_game
			latest_save_game_date = tonumber(save_game.Date)
		end
	end
	update_mach_lua_log(string.format('Finished getting latest save game: "%s"', latest_save_game.FileName))
	return latest_save_game
end


function get_line_slope(x1, y1, x2, y2)
	update_mach_lua_log(string.format("Getting line slope for points (%s, %s) and (%s, %s).", x1, y1, x2, y2))
	local line_slope = (y1 - x1) / (x1 - x2)
	return line_slope
end


function get_line_y_intercept(point_x, point_y, line_slope)
	update_mach_lua_log(string.format("Getting line y intercept with points (%s, %s) and slope %s", point_x, point_y,
		line_slope))
	local line_y_intercept = point_y - (line_slope * point_x)
	return line_y_intercept

end


function get_mach_saved_games_list()
	update_mach_lua_log(string.format('Getting Machiavelli Mod saved games list.'))
	local saved_games_list = {}
	local extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
	local mach_saved_games_list_path = path..'mach_mod\\saved_games_list.txt'
	if file_exists(mach_saved_games_list_path) then
		saved_games_list = load_table_from_file(mach_saved_games_list_path)
--		local mach_saved_games_list_file = io.open(mach_saved_games_list_path, "r")
--		while true do
--			local line = mach_saved_games_list_file:read("*line")
--			if line == nil then
--				break
--			end
--			saved_games_list[saved_games_list+1] = line
--		end
--		mach_saved_games_list_file:close()
		update_mach_lua_log(string.format('Finished getting Machiavelli Mod saved games list. %s saved games', #saved_games_list))
	else
		update_mach_lua_log('Machiavelli Mod saved games list does not exist.')
	end
	return saved_games_list
end


--function get_mach_saved_games_list()
--	update_mach_lua_log(string.format('Getting Machiavelli Mod saved games list.'))
--	local extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
--	local mach_saved_games_list_path = path..'mach_mod\\saved_games_list.txt'
--	local mach_saved_games_list = load_table_from_file(mach_saved_games_list_path)
--	update_mach_lua_log(string.format('Finished getting Machiavelli Mod saved games list.'))
--	return mach_saved_games_list
--end


function get_nationality_from_faction_id(faction_id, location)
	update_mach_lua_log(string.format('Getting nationality from faction id: "%s"', faction_id))
	location = location or nil
	local nationality_screen_name_key = nil
	local nationality = nil
	if faction_id == 'rebels' then
		nationality_screen_name_key = string.format('start_pos_regions_rebel_faction_name_%smain', tostring(location))
		update_mach_lua_log(nationality_screen_name_key)
		nationality = CampaignUI.LocalisationString(nationality_screen_name_key, true):sub(1, -2)
	else
		nationality_screen_name_key = string.format('factions_screen_adjective_%s',  tostring(faction_id))
		nationality = CampaignUI.LocalisationString(nationality_screen_name_key, true)
	end
	update_mach_lua_log(string.format('Finished getting nationality from faction id. Nationality: "%s"', nationality))
	return nationality
end


function get_num_of_elements_in_table(tbl)
	update_mach_lua_log("Getting number of elements in table.")
	local count = 0
    for idx, value in pairs(tbl) do
        count = count + 1
    end
--	if #tbl > 0 then
--		count = #tbl
--	else
--
--	end
	update_mach_lua_log(string.format('Finished getting number of elements in table. Table has "%s" elements.', count))
	return count
end


function get_perpendicular_line_slope(line_slope)
	update_mach_lua_log(string.format("Getting perpendicular line slope of line with slope %s", line_slope))
	local perpendicular_line_slope = -1 / line_slope
	return perpendicular_line_slope
end


function get_region_id_from_region_address(region_address)
	update_mach_lua_log("Getting region id from region address: "..tostring(region_address))
	local region_id = CampaignUI.RegionKeyFromAddress(region_address)
    update_mach_lua_log("Region id is: "..tostring(region_id))
    return region_id
end


function get_region_id_from_region_name(region_name)
	update_mach_lua_log("Getting region id from region name: "..tostring(region_name))
	local found_region_id
	for region_id, region_loc_str in pairs(mach_data.region_to_loc_list) do
		local loc_region_name = CampaignUI.LocalisationString(region_loc_str, true)
		if region_name == loc_region_name then
			found_region_id = region_id
			break
		end
	end
	update_mach_lua_log("Region id is: "..tostring(found_region_id))
	return found_region_id
end

function get_region_address_from_settlement_address(settlement_address)
	update_mach_lua_log("Getting region address from settlement address: "..tostring(settlement_address))
	local region_address = CampaignUI.SettlementsRegion(settlement_address)
	update_mach_lua_log("Region address is: "..tostring(region_address))
	return region_address
end


function get_region_details_from_region_address(region_address)
	update_mach_lua_log("Getting region details from region address: "..tostring(region_address))
	local region_details = CampaignUI.InitialiseRegionInfoDetails(region_address)
	update_mach_lua_log("Finished getting region details from region address.")
	return region_details
end



function get_region_id_list()
	update_mach_lua_log("Getting region id list")
	local region_id_list = {}
	local factions_list = mach_data.__faction_id_list__
	for faction_id_idx, faction_id in pairs(factions_list) do
		for regions_owned_by_faction_or_protectorates_key, regions_owned_by_faction_or_protectorates_value in pairs(CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_id) or {}) do
			if not regions_owned_by_faction_or_protectorates_value.OwnedByProtectorate then
				local region_id = CampaignUI.RegionKeyFromAddress(regions_owned_by_faction_or_protectorates_value.Address)
				region_id_list[#region_id_list+1] = region_id
			end
		end
	end
	update_mach_lua_log("Finished Getting region id list")
	return region_id_list
end

--[[
Description:
    Updates the list of player owned and allied regions. Should be called on game load, turn start and when campaign is entered
Arguments:
    n/a
Returns:
    n/a
--]]
function get_safe_regions_and_settlements_for_faction(faction_id)
	update_mach_lua_log("Getting safe regions and settlements for faction_key: "..faction_id)

	local safe_regions_and_settlements = {}
	local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_id)

	local i = 1
	for k = 1, #regions do
		safe_regions_and_settlements[i] = regions[k].Name
		i = i + 1
		safe_regions_and_settlements[i] = CampaignUI.InitialiseRegionInfoDetails(regions[k].Address).Settlement
		i = i + 1
	end

	--get allied regions
	local faction_diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(faction_id)
	--Update("Looping through allies")
	for k,v in pairs(faction_diplomacy_details.Allies) do
		local factions_regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(k)
		for kk, vv in pairs(factions_regions) do
			safe_regions_and_settlements[i] = factions_regions[kk].Name
			i = i + 1
		end
	end
	update_mach_lua_log("Finished updating safe regions and settlements for faction_key id: "..faction_id)
	return safe_regions_and_settlements
end


-- function to determine the settlement key from region key
function get_settlement_id_from_region_id(region_id)
	update_mach_lua_log('Getting settlement id from region id "'..tostring(region_id)..'"')
	for settlement_id, region_id_value in pairs(mach_data.settlement_to_region_list) do
		if region_id_value == region_id then
			update_mach_lua_log('Settlement id of region "'..tostring(region_id)..'" is "'..tostring(settlement_id)..'"')
			return settlement_id
		end
	end
end


function get_settlement_id_from_settlement_address(settlement_address)
	update_mach_lua_log('Getting settlement id from settlement address"'..tostring(settlement_address)..'"')
	local region_address = get_region_address_from_settlement_address(settlement_address)
	local region_details = get_region_details_from_region_address(region_address)
	local region_id = get_region_id_from_region_name(region_details.Name)
	local settlement_id = get_settlement_id_from_region_id(region_id)
	update_mach_lua_log('Settlement id from address is: "'..tostring(settlement_id)..'"')
	return settlement_id
end


function get_slot_from_context(slot_context)
    update_mach_lua_log("Getting current slot.")
    local last_search_slot = "town:england:cambridge"

    if conditions.SlotName(last_search_slot, slot_context) then
        return last_search_slot
    end
    for kk, vv in pairs(mach_data.slotsList) do
        if conditions.SlotName(kk, slot_context) then
            last_search_slot = kk
            return kk
        end
    end
    return "No ID slot"
end


function get_unit_culture_from_unit_context(unit_context)
	update_mach_lua_log('Getting unit culture from unit context.')
	local unit_culture = nil
	if conditions.UnitCultureType('european', unit_context) then
		unit_culture = 'european'
	elseif conditions.UnitCultureType('indian', unit_context) then
		unit_culture = 'indian'
	elseif conditions.UnitCultureType('middle_east', unit_context) then
		unit_culture = 'middle_east'
	elseif conditions.UnitCultureType('tribal', unit_context) then
		unit_culture = 'tribal'
	end
	update_mach_lua_log(string.format('Finished getting unit culture from unit context. Unit culture: "%s"', unit_culture))
	return unit_culture
end


--determine if army is located in a settlement
function is_army_obj_in_settlement(faction_key, army_obj)
    update_mach_lua_log("Determining if army is in a settlement.")
    local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_key)
    local region_id = nil
    local distance = false
    local army_in_settlement = false
    for k = 1, #regions do
		region_id = CampaignUI.RegionKeyFromAddress(regions[k].Address)
        distance = find_distance(army_obj.PosX, army_obj.PosY, mach_data.region_capital_coord_list[region_id][1], mach_data.region_capital_coord_list[region_id][2])
        if (distance < 0.001) and (distance > -0.001) and (distance ~= nil) then
            update_mach_lua_log("Army is in a settlement. Region name: "..tostring(region_id))
            return true, region_id
        end
    end
    update_mach_lua_log("Army is NOT in a settlement.")
    return false, region_id
end


--determine if army is located on a friendly fleet
function is_army_obj_on_fleet(faction_id, army_obj)
	update_mach_lua_log("Determining if army is on a friendly fleet.")
	local army_pos_x = army_obj.PosX
	local army_pos_y = army_obj.PosY
	local on_fleet = false
	local fleet_army_is_on = nil
	local faction_naval_forces = get_faction_naval_forces(faction_id)
	for naval_force_key, naval_force in pairs(faction_naval_forces) do
		if find_distance(army_pos_x, army_pos_y, naval_force.obj.PosX, naval_force.obj.PosY) < 1.55 then
			on_fleet = true
			fleet_army_is_on = naval_force
		end
	end
	local faction_diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(faction_id)
	for key, value in pairs(faction_diplomacy_details.Protectorates) do
		local faction_naval_forces = get_faction_naval_forces(value.Label)
		for faction_naval_force_key, naval_force in pairs(faction_naval_forces) do
			if find_distance(army_pos_x, army_pos_y, naval_force.obj.PosX, naval_force.obj.PosY) < 1.55 then
				on_fleet = true
				fleet_army_is_on = naval_force
			end
		end
	end

	for key, value in pairs(faction_diplomacy_details.Allies) do
		local faction_naval_forces = get_faction_naval_forces(value.Label)
		for faction_naval_force_key, naval_force in pairs(faction_naval_forces) do
			if find_distance(army_pos_x, army_pos_y, naval_force.obj.PosX, naval_force.obj.PosY) < 1.55 then
				on_fleet = true
				fleet_army_is_on = naval_force
			end
		end
	end

	if on_fleet then
		update_mach_lua_log("Army IS on a fleet under the command of: "..tostring(fleet_army_is_on.commander_name))
		return true, fleet_army_is_on
	end

	update_mach_lua_log("Army is NOT on a fleet.")
	return false, fleet_army_is_on
end


function is_array(obj)
	update_mach_lua_log("Checking if object is array.")

	local i = 0
	for item in pairs(obj) do
		i = i + 1
		if obj[i] == nil then
			update_mach_lua_log("Object is NOT array")
			return false
		end
	end
	update_mach_lua_log("Object is array")
	return true
end


--CharacterSelected event calls this
function is_character_admiral(context)
	update_mach_lua_log("Deterimining if character is admiral.")

--	local ETS = CampaignUI.EntityTypeSelected()
	if conditions.CharacterType("admiral", context) then
		update_mach_lua_log("Character is a admiral.")
		return true
	end
	update_mach_lua_log("Character is NOT a admiral.")
	return false
end


function is_character_naval_captain(context)
	update_mach_lua_log("Deterimining if character is naval captain.")

	--	local ETS = CampaignUI.EntityTypeSelected()
	if conditions.CharacterType("captain", context) then
		update_mach_lua_log("Character is a naval captain.")
		return true
	end
	update_mach_lua_log("Character is NOT a naval captain.")
	return false
end


function is_character_colonel(context)
	update_mach_lua_log("Deterimining if character is colonel.")
	if conditions.CharacterType("colonel", context) then
		update_mach_lua_log("Character is a colonel.")
		return true
	end
	update_mach_lua_log("Character is NOT a colonel.")
	return false
end


function is_character_general(context)
	update_mach_lua_log("Deterimining if character is general.")

	if conditions.CharacterType("General", context) then
		update_mach_lua_log("Character is a General.")
		return true
	end
	update_mach_lua_log("Character is NOT a General.")
	return false
end


function is_character_in_safe_region(faction, character_pointer)
	update_mach_lua_log("Checking if character of faction_key \""..faction.."\" is in safe (non attrition) region.")
	local char_details = CampaignUI.InitialiseCharacterDetails(character_pointer)
	update_mach_lua_log(char_details.Location)

	local safe_region = is_region_attrition_safe(faction, char_details.Location)

	if safe_region then
		update_mach_lua_log("Character is in safe region.")
	else
		update_mach_lua_log("Character is NOT in safe region.")
	end
	return safe_region
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
function is_region_attrition_safe(faction, region)
	update_mach_lua_log("Checking if region \""..region.."\" is attrition safe for faction_key \""..faction.."\"")
	local safe_regions_and_settlements = get_safe_regions_and_settlements_for_faction(faction)
	for i = 0, #safe_regions_and_settlements do
		if safe_regions_and_settlements[i] == region then
			update_mach_lua_log("Region \""..region.."\" is attrition safe.")
			return true
		end
	end
	update_mach_lua_log("Region \""..region.."\" is NOT attrition safe.")
	return false
end


function is_value_in_table(value_to_find, tbl)
	update_mach_lua_log(string.format('Checking if value "%s" is in table.', value_to_find))
	for idx, value in pairs(tbl) do
		if value_to_find == value then
			update_mach_lua_log(string.format('Value "%s" is in table.', value_to_find))
			return true
		end
	end
	update_mach_lua_log(string.format('Value "%s" is NOT in table!', value_to_find))
	return false
end


function isINF(value)
  return value == math.huge or value == -math.huge
end


function isNAN(value)
  return value ~= value
end


function load_mach_save_game(mach_loaded_game_id)
	update_mach_lua_log(string.format('Loading Machiavelli Mod game with game ID: %s', mach_loaded_game_id))
	mach_data.__mach_saved_games_list__ = get_mach_saved_games_list()
	local empire_save_game_file_name_no_ext = mach_data.__mach_saved_games_list__[mach_loaded_game_id].FileName:gsub(".empire_save", "")
	local loaded_game_file_name = empire_save_game_file_name_no_ext..'.mach_save'
--	local loaded_game_file_name = mach_loaded_game_id..'.mach_save'
	local extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
	local mach_load_game_file_path = path..'mach_mod\\'..loaded_game_file_name
	local loaded_tbl = load_table_from_file(mach_load_game_file_path)
	mach_data.__battles_list__ = loaded_tbl['__battles_list__']
--	if type(loaded_tbl['__battles_list__'][1].is_naval_battle, "boolean") then
--		update_mach_lua_log(loaded_tbl['__battles_list__'][1].is_naval_battle)
--	end
	--	output_table_to_mach_log(loaded_tbl['__battles_list__'][1], 1)
--	output_table_to_mach_log(loaded_tbl['__battles_list__'][1].pre_battle_units_list, 1)
--	output_table_to_mach_log(loaded_tbl['__battles_list__'][1].pre_battle_units_list['france'], 1)
	update_mach_lua_log(string.format('Finished loading Machiavelli Mod saved game.'))
	return true
end


function load_table_from_file(file_path)
	update_mach_lua_log(string.format('Loading table from file path: "%s"', file_path))
	local ftables, err = loadfile(file_path)
	if err then return _,err end
	if err then
		update_mach_lua_log(string.format('Error, could not load table from file: "%s"', file_path))
		return nil
	end
	local tables = ftables()
	for idx = 1,#tables do
		local tolinki = {}
		for i,v in pairs( tables[idx] ) do
			if type(i) == 'string' and i:find('^Pointer\<') ~= nil then
				 i = i:gsub('"', '')
			end
			if type(v) == 'string' and v:find('^Pointer\<') ~= nil then
				v = v:gsub('"', '')
			end
			if type( v ) == "table" then
				tables[idx][i] = tables[v[1]]
			end
			if type( i ) == "table" and tables[i[1]] then
				table.insert( tolinki,{ i,tables[i[1]] } )
			end
		end
		-- link indices
		for _,v in ipairs( tolinki ) do
			tables[idx][v[2]],tables[idx][v[1]] = tables[idx][v[1]],nil
		end
	end
	update_mach_lua_log(string.format('Finished loading table from file name: "%s"', file_path))
	return tables[1]
end


function message_update_loop(message_hander, time, time_increment, max_time)
	update_mach_lua_log(string.format('Running message update loop with time "%s" and time increment "%s".', time, time_increment))
	local new_time = time + time_increment
	local screen_width, screen_height = CampaignUI.ScreenSize()
	update_mach_lua_log('test2')
	local hud_width, hud_height = huds.Dimensions()
	update_mach_lua_log('test3')
	local icon_height = 64
	local stack_base = screen_height
	update_mach_lua_log('test')
	update_mach_lua_log(new_time)
	if new_time <= max_time then
		message_handler.Update(time, CampaignUI)
		message_update_loop(message_hander, new_time, time_increment, max_time)
	end
	update_mach_lua_log('Finished running message update loop.')
end


function on_campaign_armies_merge(context)
    update_mach_lua_log('MACH LIB - CampaignArmiesMerge.')
    update_mach_lua_log('MACH LIB - Finished CampaignArmiesMerge.')
end

function on_character_created(context)
    update_mach_lua_log('MACH LIB - CharacterCreated.')
    update_mach_lua_log('MACH LIB - Finished CharacterCreated.')
end

-- This function executes when a character is selected on the campaign map
-- @param contect: character context
function on_character_selected(context)
	update_mach_lua_log("MACH LIB - CharacterSelected.")
	local faction_id = get_faction_id_from_context(context, "CharacterSelected")
	if faction_id == __current_faction_turn_id__ then
		local character_details = get_character_details_from_character_context(context, "CharacterSelected")
		if not character_details.IsNaval then
			mach_data.__all_factions_military_forces_list__[faction_id][character_details.Address] = mach_classes.Army:new(character_details, faction_id)
		else
			mach_data.__all_factions_military_forces_list__[faction_id][character_details.Address] = mach_classes.Navy:new(character_details, faction_id)
		end
	end
    update_mach_lua_log("MACH LIB - Finished CharacterSelected.")
end


-- This function executes when the left mouse button click is released
-- @param contect: mouse clicka context
function on_component_left_click_up(context)
	update_mach_lua_log("MACH LIB - ComponentLClickUp")
	if __wali_is_on_campaign_map__ then
		if not mach.__mach_enabled_mods_msg_box_displayed__ then
			mach.show_mach_enabled_mods_text_in_advice_box()
		end
		local ETS = CampaignUI.EntityTypeSelected()
		if not ETS.Character and not ETS.Unit then
			__wali_is_first_click_on_army__ = false
			__wali_army_is_selected__ = false
			--set this to nil here in case player clicks army X -> other non-army object -> army x again,
			--in which case checks would fail
			__wali_previously_selected_character_pointer__ = nil
		end
    end
    update_mach_lua_log("MACH LIB - Finished ComponentLClickUp")
end



-- This function executes on faction_key turn start.
-- @param contect: faction_key context
function on_faction_turn_end(context)
	update_mach_lua_log("MACH LIB - FactionTurnEnd.")
	mach_data.__all_factions_military_forces_list__[__current_faction_turn_id__] = get_faction_military_forces(__current_faction_turn_id__)
	update_mach_lua_log("MACH LIB - Finished FactionTurnEnd.")
end


-- This function executes on faction_key turn start.
-- @param contect: faction_key context
function on_faction_turn_start(context)
	update_mach_lua_log("MACH LIB - FactionTurnStart.")
	__current_year__ = CampaignUI.CurrentYear()
	__current_turn__ = CampaignUI.CurrentTurn()
	__current_faction_turn_id__ = get_faction_id_from_context(context, "FactionTurnStart")
    mach_data.__all_factions_military_forces_list__[__current_faction_turn_id__] = get_faction_military_forces(__current_faction_turn_id__)
    update_mach_lua_log("MACH LIB - Finished FactionTurnStart.")
end


function on_loading_game(context)
	update_mach_lua_log("MACH LIB - LoadingGame.")
	local mach_loaded_game_id = scripting.game_interface:load_value(-1, context)
	if mach_loaded_game_id ~= -1 then
		update_mach_lua_log(string.format('MACH save game ID loading: %s', mach_loaded_game_id))
		if not load_mach_save_game(mach_loaded_game_id) then
			update_mach_lua_log("Error, could not load Machiavelli Mod saved game!")
		end
	else
		update_mach_lua_log("MACH save game id value is -1. No MACH save game associated with Empire save!")
	end
	update_mach_lua_log("MACH LIB - Finished LoadingGame.")
end


function on_panel_closed_campaign(context)
	update_mach_lua_log("MACH LIB - PanelClosedCampaign")

	if __saving_game__ then
		__saving_game__ = false
--		update_mach_lua_log('nerd')

--		update_mach_lua_log(mach_save_game_file_path)
		if not save_mach_save_game() then
			update_mach_lua_log("Error, unable to save game of Machiavelli's Mods!")
		end
	end
	update_mach_lua_log("MACH LIB - Finished PanelClosedCampaign")
end


function on_panel_opened_campaign(context)
	update_mach_lua_log("MACH LIB - PanelOpenedCampaign")
	update_mach_lua_log("MACH LIB - Finished PanelOpenedCampaign")
end


function on_region_rebels(context)
	update_mach_lua_log("MACH LIB - RegionRebels.")
--	for rebel_faction_id_idx  = 1, #mach_data.faction_id_list_pirates_and_rebels do
--        local rebel_faction_id = mach_data.faction_id_list_pirates_and_rebels[rebel_faction_id_idx]
--		mach_data.__all_factions_military_forces_list__[rebel_faction_id] = get_faction_military_forces(rebel_faction_id)
--	end
	update_mach_lua_log("MACH LIB - Finished RegionRebels.")
end


function on_saving_game(context)
	update_mach_lua_log("MACH LIB - SavingGame")
	__saving_game__ = true
	__mach_save_game_id__ = #mach_data.__mach_saved_games_list__ + 1
	update_mach_lua_log(string.format('MACH saving game with ID: %s', __mach_save_game_id__))
	scripting.game_interface:save_value(__mach_save_game_id__, context)
	update_mach_lua_log("MACH LIB - Finished SavingGame")
end


function on_time_trigger(context)
	update_mach_lua_log("MACH LIB - TimeTrigger")
	update_mach_lua_log("MACH LIB - Finished TimeTrigger")
end


-- This function executes when UI is created
-- @param contect: UI context
function on_ui_created(context)
	update_mach_lua_log("MACH LIB - UICreated.")

	update_mach_lua_log(context.string)

	if context.string == "Campaign UI" then
		__current_year__ = CampaignUI.CurrentYear()
		__current_turn__ = CampaignUI.CurrentTurn()
		__current_season_string__ = CampaignUI.CurrentSeasonString()
		__unit_scale_factor__ = CampaignUI.UnitScaleFactor()
		__player_faction_id__ = CampaignUI.PlayerFactionId()
		__wali_is_on_campaign_map__ = true
		__wali_m_root__ = UIComponent(context.component)

		if mach_config.__MACH_DEBUG_MODE__ then
			set_fog_of_war(false)
		end
		mach_data.__faction_id_list__ = get_faction_id_list()
		__current_faction_turn_id__ = get_faction_id_from_context(context, "UICreated")
		mach_data.__character_names_list__ = get_character_names_list()
		mach_data.__region_id_list__ = get_region_id_list()
		mach_data.__all_factions_military_forces_list__ = get_all_factions_military_forces()
	end
	update_mach_lua_log("MACH LIB - Finished UICreated.")
end


function output_globals_to_mach_log(obj,str)
	update_mach_lua_log("Outputting global variables to mach log.")

	seen[t]=true
	local s={}
	local n=0
	for k in pairs(obj) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		update_mach_lua_log(tostring(str).."- "..tostring(v))
		v=t[v]
		if type(v)=="table" and not seen[v] then
			output_globals_to_mach_log(v,str.."\t")
		end
	end
	update_mach_lua_log("Finished outputting global variables to mach log.")
end

function output_obj_attributes_to_mach_log(obj)
	update_mach_lua_log("Outputting object attributes to mach log.")
	for key,value in pairs(getmetatable(obj)) do
		update_mach_lua_log("Found obj member: " .. key);
	end
end

function output_obj_to_mach_log(obj, tab_num)
	update_mach_lua_log("Outputting object to mach log.")
	tab_num = tab_num or 1
	local tab_str = '\t'
	for idx = 1, tab_num do
		tab_str = '\t'..tostring(tab_str)
	end
	if type(obj) == "table" then
		update_mach_lua_log("Object is table.")
		for key1, value1 in pairs(obj) do
			pdate_mach_lua_log('pdate_mach_lua_log')
			update_mach_lua_log(tostring(tab_str)..'"'..tostring(key1)..'": "'..tostring(value1)..'"')
			output_obj_to_mach_log(value1, tab_num + 1)
			-- if type(value1) == "table" then
				
--				for key2, value2 in pairs(data) do
--					update_mach_lua_log('\t"'..tostring(key2)..'": "'..tostring(value2)..'"')
--					if type(value2) == "table" then
--						for key3, value3 in pairs(value2) do
--							update_mach_lua_log('\t\t"'..tostring(key3)..'": "'..tostring(value3)..'"')
--						end
--					end
--				end
--			end
		end
	elseif is_array(obj) then
		update_mach_lua_log("Object is array.")

		for idx = 1, #obj do
			update_mach_lua_log(tostring(tab_str)..'"'..tostring(idx)..'": "'..tostring(obj[idx])..'"')
			output_obj_to_mach_log(obj[idx], tab_num + 1)
		end
	else
		update_mach_lua_log("Object is neither table nor array.")
		update_mach_lua_log(tostring(tab_str)..'"'..tostring(obj)..'"')
	end
end


function output_table_to_mach_log(tbl, level)
	level = level or 10
    update_mach_lua_log("")
    update_mach_lua_log("")
    update_mach_lua_log("Outputting table to mach log.")
	if type(tbl) == "table" and level >= 1 then
		update_mach_lua_log(tostring(tbl))
		for key1, value1 in pairs(tbl) do
			update_mach_lua_log('\t"'..tostring(key1)..'": "'..tostring(value1)..'"')
			if type(value1) == "table" and level >= 2 then
				for key2, value2 in pairs(data) do
					update_mach_lua_log('\t\t"'..tostring(key2)..'": "'..tostring(value2)..'"')
					if type(value2) == "table" then
						for key3, value3 in pairs(value2) do
							update_mach_lua_log('\t\t\t"'..tostring(key3)..'": "'..tostring(value3)..'"')
							if type(value3) == "table" and level >= 3 then
								for key4, value4 in pairs(value3) do
									update_mach_lua_log('\t\t\t\t"'..tostring(key4)..'": "'..tostring(value4)..'"')
									if type(value4) == "table" and level >= 4  then
										for key5, value5 in pairs(value4) do
											update_mach_lua_log('\t\t\t\t\t"'..tostring(key5)..'": "'..tostring(value5)..'"')
                                            if type(value5) == "table" and level >= 5  then
                                                for key6, value6 in pairs(value5) do
                                                    update_mach_lua_log('\t\t\t\t\t\t"'..tostring(key6)..'": "'..tostring(value6)..'"')
                                                end
                                            end
										end
									end
								end
							end
						end
					end
                end
            end
		end
	else
		update_mach_lua_log(tostring(tbl))
	end
    update_mach_lua_log("")
    update_mach_lua_log("")
end


function remove_str_accents(str)
	update_mach_lua_log(string.format('Removing accents from string: %s', str))
	local table_accents = {}
	table_accents["À"] = "A"
	table_accents["Á"] = "A"
	table_accents["Â"] = "A"
	table_accents["Ã"] = "A"
	table_accents["Ä"] = "A"
	table_accents["Å"] = "A"
	table_accents["Æ"] = "AE"
	table_accents["Ç"] = "C"
	table_accents["È"] = "E"
	table_accents["É"] = "E"
	table_accents["Ê"] = "E"
	table_accents["Ë"] = "E"
	table_accents["Ì"] = "I"
	table_accents["Í"] = "I"
	table_accents["Î"] = "I"
	table_accents["Ï"] = "I"
	table_accents["Ð"] = "D"
	table_accents["Ñ"] = "N"
	table_accents["Ò"] = "O"
	table_accents["Ó"] = "O"
	table_accents["Ô"] = "O"
	table_accents["Õ"] = "O"
	table_accents["Ö"] = "O"
	table_accents["Ø"] = "O"
	table_accents["Ù"] = "U"
	table_accents["Ú"] = "U"
	table_accents["Û"] = "U"
	table_accents["Ü"] = "U"
	table_accents["Ý"] = "Y"
	table_accents["Þ"] = "P"
	table_accents["ß"] = "s"
	table_accents["à"] = "a"
	table_accents["á"] = "a"
	table_accents["â"] = "a"
	table_accents["ã"] = "a"
	table_accents["ä"] = "a"
	table_accents["å"] = "a"
	table_accents["æ"] = "ae"
	table_accents["ç"] = "c"
	table_accents["è"] = "e"
	table_accents["é"] = "e"
	table_accents["ê"] = "e"
	table_accents["ë"] = "e"
	table_accents["ì"] = "i"
	table_accents["í"] = "i"
	table_accents["î"] = "i"
	table_accents["ï"] = "i"
	table_accents["ð"] = "eth"
	table_accents["ñ"] = "n"
	table_accents["ò"] = "o"
	table_accents["ó"] = "o"
	table_accents["ô"] = "o"
	table_accents["õ"] = "o"
	table_accents["ö"] = "o"
	table_accents["ø"] = "o"
	table_accents["ù"] = "u"
	table_accents["ú"] = "u"
	table_accents["û"] = "u"
	table_accents["ü"] = "u"
	table_accents["ý"] = "y"
	table_accents["þ"] = "p"
	table_accents["ÿ"] = "y"

	local normalised_string = ''

	local normalised_string = str: gsub("[%z\1-\127\194-\244][\128-\191]*", table_accents)
	update_mach_lua_log(string.format('Finished removing accents from string. String with accents removed: %s', normalised_string))
	return normalised_string
end


-- Round value to given decimal places
-- @param num: value to be rounded as dboule
-- @param idp: number of decimal places as integer
-- @return: rounded value
function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end


function save_mach_save_game()
	update_mach_lua_log(string.format('Saving Machiavelli Mod game to file path.'))
	local latest_save_game = get_latest_save_game()
	local extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
	os.execute('mkdir "'..path..'mach_mod"')
	local empire_save_game_file_name_no_ext = latest_save_game.FileName:gsub(".empire_save", "")
	local mach_save_game_file_path = path..'mach_mod\\'..empire_save_game_file_name_no_ext..'.mach_save'
	update_mach_lua_log(string.format('Saving MACH save game to: "%s"', mach_save_game_file_path))
	mach_data.__mach_saved_games_list__[__mach_save_game_id__] = latest_save_game
	save_mach_saved_games_list()
	__mach_save_game_id__ = nil
	local mach_save_game_file = assert(io.open(mach_save_game_file_path, "w"))
	local tbl_to_save = {}
	--	mach_data.__battles_list__.pre_battle_winner_military_forces[1]
	--	output_table_to_mach_log(mach_data.__battles_list__[1], 1)
	--	update_mach_lua_log('terry')
	--	dofile("Pickle.lua")
	--	pickle_file = require "WALI/Pickle"
	--
	--	update_mach_lua_log('terry2')
	--	update_mach_lua_log(pickle_file.pickle(mach_data.__battles_list__))
	--	update_mach_lua_log('terry1')
	tbl_to_save['save_game'] = latest_save_game
	tbl_to_save['__battles_list__'] = mach_data.__battles_list__
	--	local json = require("json")
	if not save_table_to_file(tbl_to_save, mach_save_game_file_path) then
		update_mach_lua_log('Error, unable to save mach_data.__battles_list__ table tof file!')
		return false
	end
	update_mach_lua_log(string.format('Finished saving Machiavelli Mod game to file path: "%s"', mach_save_game_file_path))
	return true
end


function save_mach_saved_games_list()
	update_mach_lua_log(string.format('Saving Machiavelli Mod saved games list.'))
	local extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
	local mach_saved_games_list_path = path..'mach_mod\\saved_games_list.txt'
	if not save_table_to_file(mach_data.__mach_saved_games_list__, mach_saved_games_list_path) then
		update_mach_lua_log('Error, unable to save saved games list table to file!')
		return false
	end
	update_mach_lua_log(string.format('Finished saving Machiavelli Mod saved games list.'))
	return true
end


function save_table_to_file(tbl, file_path)
	update_mach_lua_log(string.format('Saving table to file: "%s"', file_path))
	local charS, charE = "   ","\n"
	local file, err = io.open( file_path, "wb" )
	if err then return err end

	-- initiate variables for save procedure
	local tables,lookup = { tbl },{ [tbl] = 1 }
	file:write( "return {"..charE )

	for idx,t in ipairs( tables ) do
		file:write( "-- Table: {"..idx.."}"..charE )
		file:write( "{"..charE )
		local thandled = {}
		for i,v in ipairs( t ) do
			thandled[i] = true
			local stype = type( v )
			-- only handle value
			if stype == "table" then
				if not lookup[v] then
					table.insert( tables, v )
					lookup[v] = #tables
				end
				file:write( charS.."{"..lookup[v].."},"..charE )
			elseif stype == "string" then
				file:write(  charS..export_string( v )..","..charE )
			elseif stype == "number" then
				file:write(  charS..tostring( v )..","..charE )
			else
				update_mach_lua_log(string.format('only handle value: %s', stype))
			end
		end

		for i,v in pairs( t ) do
			-- escape handled values
			if (not thandled[i]) then

				local str = ""
				local stype = type( i )
				-- handle index
				if stype == "table" then
					if not lookup[i] then
						table.insert( tables,i )
						lookup[i] = #tables
					end
					str = charS.."[{"..lookup[i].."}]="
				elseif stype == "string" then
					str = charS.."["..export_string( i ).."]="
				elseif stype == "number" then
					str = charS.."["..tostring( i ).."]="
				else
					update_mach_lua_log(string.format('handle index: %s', stype))
				end

				if str ~= "" then
					stype = type( v )
					-- handle value
					if stype == "table" then
						if not lookup[v] then
							table.insert( tables,v )
							lookup[v] = #tables
						end
						file:write( str.."{"..lookup[v].."},"..charE )
					elseif stype == "string" then
						file:write( str..export_string( v )..","..charE )
					elseif stype == "number" then
						file:write( str..tostring( v )..","..charE )
					elseif stype == "boolean" then
						file:write( str..tostring( v )..","..charE )
					elseif stype == "userdata" then
						file:write( str..'"'..tostring( v )..'",'..charE )
					else
						update_mach_lua_log(string.format('handle value: %s', stype))
					end
				end
			end
		end
		file:write( "},"..charE )
	end
	file:write( "}" )
	file:close()
	update_mach_lua_log(string.format('Finished saving table to file: "%s"', file_path))
	return true
end


--function serializeImpl( t, tTracking, sIndent )
--	local sType = type(t)
--	if sType == "table" then
--		if tTracking[t] ~= nil then
--			error( "Cannot serialize table with recursive entries", 0 )
--		end
--		tTracking[t] = true
--
--		if next(t) == nil then
--			-- Empty tables are simple
--			return "{}"
--		else
--			-- Other tables take more work
--			local sResult = "{\n"
--			local sSubIndent = sIndent .. "  "
--			local tSeen = {}
--			for k,v in ipairs(t) do
--				tSeen[k] = true
--				sResult = sResult .. sSubIndent .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
--			end
--			for k,v in pairs(t) do
--				if not tSeen[k] then
--					local sEntry
--					if type(k) == "string" and not g_tLuaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" ) then
--						sEntry = k .. " = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
--					else
--						sEntry = "[ " .. serializeImpl( k, tTracking, sSubIndent ) .. " ] = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
--					end
--					sResult = sResult .. sSubIndent .. sEntry
--				end
--			end
--			sResult = sResult .. sIndent .. "}"
--			return sResult
--		end
--
--	elseif sType == "string" then
--		return string.format( "%q", t )
--
--	elseif sType == "number" or sType == "boolean" or sType == "nil" then
--		return tostring(t)
--
--	else
--		error( "Cannot serialize type "..sType, 0 )
--
--	end
--end


-- This function prints all global variables to MACH log
-- @param obj: Object to check globals for.
-- @param str: Name of object to check.
local seen={}

-- Set Debug Mode.
-- @param value: boolean value to set for debugging and logging. Must be set to true for logging.
function set_debug_mode(value)
    mach_config.__MACH_DEBUG_MODE__ = value
end


function set_fog_of_war(set_fog_of_war_to)
    update_mach_lua_log(string.format('Setting fog of war to "%s"', tostring(set_fog_of_war_to)))
    scripting.game_interface:show_shroud(set_fog_of_war_to)
	update_mach_lua_log(string.format('Finished setting fog of war to "%s"', tostring(set_fog_of_war_to)))
end


-- Pop up smple dialogue box.
-- @param msg: String to display in pop up message box.
function show_dialogue_box(msg)
	update_mach_lua_log('Showing simple dialogue box: "'..tostring(msg)..'"')
	local utils = require("Utilities")
	local panel_manager = utils.Require("panelmanager")
	panel_manager.OpenPanel("dialogue_box", true, "Initialise", tostring(msg))
end


-- Pop up message box.
function show_message_box(auto_show, screen_height, screen_width, icon, text, event, image, title, data, layout, requires_response)
	update_mach_lua_log('Showing message box with title "'..tostring(title)..'" and text "'..tostring(text)..'" and icon "'..tostring(icon)..'" and image "'..tostring(image)..'"')
	local utils = require("Utilities")
	local panel_manager = utils.Require("panelmanager")
	local utils = require("Utilities")
	local message_handler = utils.Require("message_handler")
--	details = {
--		AutoShow = false,
--		ScreenHeight = 960,
--		ScreenWidth = 1280,
--		Icon = "data/ui/eventicons/navy.tga",
--		Text = "A terrible storm broke out and  we lost a few ships that transported the slaves in the colony. Our losses were " .. tostring(math.floor(PirLost)) .. " coins.",
--		Event = "character_dies_natural_causes",
--		Image = "data/ui/EventPics/european/naval loose.tga",
--		Title = CampaignUI.LocalisationString("storm_title", true),
--		Data = {SubTitle = "", MoviePath = ""},
--		Layout = "standard",
--		RequiresResponse = false
--	}
	local details = {
		AutoShow = auto_show,
		ScreenHeight = screen_height,
		ScreenWidth = screen_width,
		Icon = icon,
		Text = text,
		Event = event,
		Image = image,
		Title = title,
		Data = data,
		Layout = layout,
		RequiresResponse = requires_response
    }
    CampaignUI.DismissCurrentAdvice()
    message_handler.ShowMessage(details, CampaignUI)
--	message_update_loop(message_handler, 0, 100, 5000)
	update_mach_lua_log('Finished showing message box.')
end


--function split_str(str, pat)
--	update_mach_lua_log(string.format('Splitting string "%s".', str))
--	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
--	local fpat = "(.-)" .. pat
--	local last_end = 1
--	local s, e, cap = str:find(fpat, 1)
--	while s do
--		if s ~= 1 or cap ~= "" then
--			table.insert(t,cap)
--		end
--		last_end = e+1
--		s, e, cap = str:find(fpat, last_end)
--	end
--	if last_end <= #str then
--		cap = str:sub(last_end)
--		table.insert(t, cap)
--	end
--	update_mach_lua_log(string.format('Finished splitting string "%s".', str))
--	return t
--end


function split_str(str, sep)
--	update_mach_lua_log(string.format('Splitting string "%s".', str))
	local result = {}
	local regex = ("([^%s]+)"):format(sep)
	for each in str:gmatch(regex) do
--		update_mach_lua_log(each)
		result[#result+1] = each
	end
--	update_mach_lua_log(string.format('Finished splitting string "%s". Number of split elements: %s.', str, #result))
	return result
end


function string_starts_with(string_to_check, starts_with)
	update_mach_lua_log('Checking if string "%s" starts with "%s"', string_to_check, starts_with)
	return string.sub(string_to_check,1,string.len(starts_with))==starts_with
end


-- Writes to the MACH log file
-- @param update_arg: what to write to mach log file as string
function update_mach_lua_log(update_arg)
--	if not mach_config.__MACH_DEBUG_MODE__ then
--		return
--	end
	local date_and_time = os.date("%Y-%m-%d %H:%M.%S")
	local file_name_str = debug.getinfo(2, "S").source:sub(2)
	local file_name = file_name_str:match("^.*/(.*).lua$") or file_name_str
	local func_name = debug.getinfo(2).name
	local mach_log_handler = io.open(__mach_log_file__,"a")

	if type(update_arg) ~= "nil" then
		mach_log_handler:write("\n[".. date_and_time .."]\t\t"..tostring(file_name).."."..tostring(func_name)..": "..tostring(update_arg))
	elseif type(update_arg) == "nil" then
		mach_log_handler:write("\n[".. date_and_time .."]\t\tLogging error: input type nil")
	end
	mach_log_handler:close()
end


function update_numbered_list(existing_list, new_value)
	update_mach_lua_log(string.format('Adding new value "%s" to list if not already exists.', new_value))
	local found_new_value = false
	for _, value in pairs(existing_list) do
		if value == new_value then
			found_new_value = true
			break
		end
	end
	if not found_new_value then
		existing_list[#existing_list+1] = new_value
	end
	update_mach_lua_log(string.format('Finished adding new value "%s" to list if not already exists.', new_value))
	return existing_list
end




