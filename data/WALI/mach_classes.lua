module(..., package.seeall)


wali = require "WALI/WALI"
mach_data = require "WALI/mach_data"
mach_lib = require "WALI/mach_lib"
mach_config = require "WALI/mach_config"


--Army class
Army = setmetatable({}, {__index = MilitaryForce})
Army.__index = Army
function Army:new (character_details, faction_id, character_context)
	mach_lib.update_mach_lua_log("Initializing Army.")
	faction_id = faction_id or nil
	character_context = character_context or nil
	local self = setmetatable(MilitaryForce:new(character_details, faction_id, character_context), Army)
	self.garrison_address = nil
	self.is_in_garrison = false
	self.is_on_fleet = false
	self.fleet_on = nil
	self.is_in_settlement = false
	self.settlement_in_name = nil
	self.settlement_in_id = nil
	self.settlement_in_region_id = nil
	self.is_in_fort = false
	self.fort_in_name = nil

	if character_details then
--		mach_lib.update_mach_lua_log("testing")
		self.garrison_address = CampaignUI.CharacterResidence(self.address)
--		mach_lib.update_mach_lua_log("testing1")
		mach_lib.update_mach_lua_log(self.garrison_address)
		if self.garrison_address then
			mach_lib.update_mach_lua_log(string.format('Garrison address: %s', tostring(self.garrison_address)))
			mach_lib.update_mach_lua_log("testing2")

			local garrison_entities = CampaignUI.RetrieveContainedEntitiesFromGarrison(self.garrison_address, self.address)
			self.is_in_settlement, self.settlement_in_id = mach_lib.is_location_settement(self.location)
			if self.is_in_settlement then
				mach_lib.update_mach_lua_log("Character is in settlement.")
				self.settlement_in_name = garrison_entities.ContainerName
				self.settlement_in_region_id = mach_lib.get_region_id_from_settlement_name(self.settlement_in_name)
			elseif garrison_entities.ContainerName:find('Fort ') then
				mach_lib.update_mach_lua_log("Character is in fort.")
				self.is_in_fort = true
				self.fort_in_name = garrison_entities.ContainerName
			end
		else
			self.is_on_fleet, self.fleet_on = mach_lib.is_army_obj_on_fleet(self.obj)
		end

--		self.is_in_settlement, self.settlement_in_region_id = mach_lib.is_army_obj_in_settlement(self.faction_id, self.obj)
--		if self.is_in_settlement then
--			self.settlement_in_id = mach_lib.get_settlement_id_from_region_id(self.settlement_in_region_id)
--		else
--			self.settlement_in_id = nil
--		end

	elseif character_context then
		mach_lib.update_mach_lua_log("testing 190")
		if conditions.CharacterInBuildingOfChain("government", character_context) or conditions.CharacterInBuildingOfChain("government_minor", character_context) or conditions.CharacterInBuildingOfChain("tribal_government", character_context) or conditions.CharacterInBuildingOfChain("tribal_playable_government", character_context) then
			mach_lib.update_mach_lua_log("Character is in settlement.")
			self.is_in_settlement = true
			self.settlement_in_name = self.location
			self.settlement_in_id = mach_lib.get_settlement_id_from_settlement_name(self.settlement_in_name)
			self.settlement_in_region_id = mach_lib.get_region_id_from_settlement_name(self.settlement_in_name)
		elseif conditions.CharacterInBuildingOfChain("fort", character_context) then
			mach_lib.update_mach_lua_log("Character is in fort.")
			self.is_in_fort = true
			self.fort_in_name = self.location
		end
--		self.is_in_settlement = false
--		self.settlement_in_region_id = self.location
--		self.settlement_in_id = nil
--		self.is_in_fort = false
--		self.is_in_settlement = mach_lib.is_value_in_table(self.location, mach_data.__settlement_names_list__)
--		self.is_in_fort = self.location:gmatch('Fort') or false
	end

	self.supplier = nil
	mach_lib.update_mach_lua_log(string.format('Finished initializing army of "%s" under command of "%s"', self.faction_id, self.commander_name))
	return self
end


--Battle class
Battle = {}
Battle.__index = Battle
function Battle:new ()
	mach_lib.update_mach_lua_log(string.format('Initializing Battle with unique id: %s', #mach_data.__battles_list__ + 1))
	local self = setmetatable(
		{
			battle_unique_id = #mach_data.__battles_list__ + 1;
			battle_name = nil;
			pos_x = nil;
			pos_y = nil;
			location = nil;
			year = mach_lib.__current_year__;
			turn = mach_lib.__current_turn__;
			is_major_battle = false;
			is_naval_battle = false;
			is_player_battle = false;
			is_siege = false;
			is_settlement_siege = false;
			besieged_settlement_id = nil;
			besieged_settlement_name = nil;
			is_fort_siege = false;
			besieged_fort_name = nil;
			winner_faction_ids = {};
			loser_faction_ids = {};
			winner_commander_names = {};
			loser_commander_names = {};
			winner_soldiers_on_ships_commander_names = {};
			loser_soldiers_on_ships_commander_names = {};
			winner_full_commander_names = {};
			loser_full_commander_names = {};
			winner_soldiers_on_ships_full_commander_names = {};
			loser_soldiers_on_ships_full_commander_names = {};
			winner_culture = nil;
			loser_culture = nil;
			winner_nationality = nil;
			loser_nationality = nil;
			winner_is_attacker = nil;
			winner_is_besieger = false;
			attacker_faction_ids = {};
			defender_faction_ids = {};
			attacker_culture = nil;
			defender_culture = nil;
			attacker_nationality = nil;
			defender_nationality = nil;
			pre_battle_winner_military_forces = {};
			pre_battle_loser_military_forces = {};
			post_battle_winner_military_forces = {};
			post_battle_loser_military_forces = {};
			pre_battle_soldiers = 0;
			pre_battle_winner_soldiers = 0;
			pre_battle_loser_soldiers = 0;
			post_battle_soldiers = 0;
			post_battle_winner_soldiers = 0;
			post_battle_loser_soldiers = 0;
			winner_soldier_casualties = 0;
			loser_soldier_casualties = 0;
			pre_battle_ships = 0;
			pre_battle_ships_list = {};
			pre_battle_winner_ships = 0;
			pre_battle_winner_ships_list = {};
			pre_battle_loser_ships = 0;
			pre_battle_loser_ships_list = {};
			post_battle_ships = 0;
			post_battle_ships_list = {};
			post_battle_winner_ships = 0;
			post_battle_winner_ships_list = {};
			post_battle_loser_ships = 0;
			post_battle_loser_ships_list = {};
			pre_battle_units = 0;
			pre_battle_units_list = {};
			pre_battle_winner_units = 0;
			pre_battle_winner_units_list = {};
			pre_battle_loser_units = 0;
			pre_battle_loser_units_list = {};
			post_battle_units = 0;
			post_battle_units_list = {};
			post_battle_winner_units = 0;
			post_battle_winner_units_list = {};
			post_battle_loser_units = 0;
			post_battle_loser_units_list = {};
			winner_commander_casualties_list = {};
			winner_unit_casualties = 0;
			winner_unit_casualties_list = {};
			winner_unit_prizes = 0;
			winner_unit_prizes_list = {};
			winner_ship_casualties = 0;
			winner_ship_casualties_list = {};
			winner_ship_prizes = 0;
			winner_ship_prizes_list = {};
			loser_commander_casualties_list = {};
			loser_unit_casualties = 0;
			loser_unit_casualties_list = {};
			loser_unit_captured = 0;
			loser_unit_captured_list = {};
			loser_ship_captured = 0;
			loser_ship_captured_list = {};
			loser_ship_casualties = 0;
			loser_ship_casualties_list = {};
			total_soldier_casualties = 0;
			total_ship_casualties = 0;
			total_ship_casualties_list = {};
			total_unit_casualties = 0;
			total_unit_casualties_list = {};
			message_auto_show = nil;
			message_screen_height = nil;
			message_screen_width = nil;
			message_icon = nil;
			message_event = nil;
			message_image = nil;
			message_title = nil;
			message_text = nil;
			message_data = nil;
			message_layout = nil;
			message_requires_response = nil;
		},
		Battle
	)
	mach_lib.update_mach_lua_log(string.format('Finished initializing Battle'))
	return self
end


function Battle:add_loser_military_force (loser_military_force, is_pre_battle, is_attacker)
	mach_lib.update_mach_lua_log(string.format('Adding loser military force to Battle object of "%s" units and "%s" ships under command of "%s" of "%s" and is_pre_battle "%s".', loser_military_force.num_of_units, loser_military_force.num_of_ships, loser_military_force.commander_name, loser_military_force.faction_id, tostring(is_pre_battle)))
	self.pre_battle_ships_list[loser_military_force.faction_id] = self.pre_battle_ships_list[loser_military_force.faction_id] or {}
	self.pre_battle_loser_ships_list[loser_military_force.faction_id] = self.pre_battle_loser_ships_list[loser_military_force.faction_id] or {}
	self.post_battle_ships_list[loser_military_force.faction_id] = self.post_battle_ships_list[loser_military_force.faction_id] or {}
	self.post_battle_loser_ships_list[loser_military_force.faction_id] = self.post_battle_loser_ships_list[loser_military_force.faction_id] or {}
	self.loser_ship_casualties_list[loser_military_force.faction_id] = self.loser_ship_casualties_list[loser_military_force.faction_id] or {}
	self.total_ship_casualties_list[loser_military_force.faction_id] = self.total_ship_casualties_list[loser_military_force.faction_id] or {}
	self.pre_battle_units_list[loser_military_force.faction_id] = self.pre_battle_units_list[loser_military_force.faction_id] or {}
	self.pre_battle_loser_units_list[loser_military_force.faction_id] = self.pre_battle_loser_units_list[loser_military_force.faction_id] or {}
	self.post_battle_units_list[loser_military_force.faction_id] = self.post_battle_units_list[loser_military_force.faction_id] or {}
	self.post_battle_loser_units_list[loser_military_force.faction_id] = self.post_battle_loser_units_list[loser_military_force.faction_id] or {}
	self.loser_unit_casualties_list[loser_military_force.faction_id] = self.loser_unit_casualties_list[loser_military_force.faction_id] or {}
	self.total_unit_casualties_list[loser_military_force.faction_id] = self.total_unit_casualties_list[loser_military_force.faction_id] or {}
	self.loser_culture = self.loser_culture or loser_military_force.culture
	self.loser_nationality = self.loser_nationality or loser_military_force.nationality

	if mach_lib.__player_faction_id__ == loser_military_force.faction_id then
		self.is_player_battle = true
	end
	if #self.attacker_faction_ids > 0 then
		is_attacker = is_attacker or false
	else
		is_attacker = is_attacker or true
	end
	if is_attacker then
		self.winner_is_attacker = false
		self.attacker_faction_ids = mach_lib.update_numbered_list(self.attacker_faction_ids, loser_military_force.faction_id)
		self.attacker_culture = self.attacker_culture or loser_military_force.culture
		self.attacker_nationality = self.attacker_nationality or loser_military_force.nationality
	else
		self.winner_is_attacker = true
		self.defender_faction_ids = mach_lib.update_numbered_list(self.defender_faction_ids, loser_military_force.faction_id)
		self.defender_culture = self.defender_culture or loser_military_force.culture
		self.defender_nationality = self.defender_nationality or loser_military_force.nationality
	end
	mach_lib.update_mach_lua_log('test')

	if #self.pre_battle_loser_military_forces == 0 and #self.post_battle_loser_military_forces == 0 then
		if is_pre_battle then
--			mach_lib.update_mach_lua_log('test 1')
--			self.is_siege = loser_military_force.is_in_settlement or loser_military_force.is_in_fort
--			mach_lib.update_mach_lua_log('test 2')
--			self.is_settlement_siege = loser_military_force.is_in_settlement or false
--			self.is_fort_siege = loser_military_force.is_in_fort or false
--			mach_lib.update_mach_lua_log('test 3')
--			mach_lib.update_mach_lua_log('test 4')
--			if self.is_settlement_siege and self.besieged_settlement_id then
--				mach_lib.update_mach_lua_log('test 5')
--				self.besieged_settlement_id = loser_military_force.settlement_in_id
--				mach_lib.update_mach_lua_log(self.besieged_settlement_id)
--				self.besieged_settlement_name = loser_military_force.settlement_in_name
----				self.besieged_settlement_name = CampaignUI.LocalisationString(mach_data.settlement_to_loc_list[self.besieged_settlement_id], true)
--				mach_lib.update_mach_lua_log('test 6')
--			elseif self.is_fort_siege then
--				self.besieged_fort_name = loser_military_force.location
--			end
			mach_lib.update_mach_lua_log('test 7')
		end
	end
--	mach_lib.update_mach_lua_log('test2')

	self.loser_faction_ids = mach_lib.update_numbered_list(self.loser_faction_ids, loser_military_force.faction_id)
	self.loser_commander_names = mach_lib.update_numbered_list(self.loser_commander_names, loser_military_force.commander_type_and_name)
	self.loser_full_commander_names = mach_lib.update_numbered_list(self.loser_full_commander_names, loser_military_force.commander_nationality_and_type_and_name)
--	mach_lib.update_mach_lua_log('test3')

	if is_pre_battle then
		mach_lib.update_mach_lua_log('Pre-Battle loser')

		if loser_military_force.is_in_settlement then
			self.is_siege = true
			self.is_settlement_siege = true
			if self.winner_is_attacker then
				self.winner_is_besieger = true
			end
			self.besieged_settlement_id = loser_military_force.settlement_in_id
			self.besieged_settlement_name = loser_military_force.settlement_in_name
			self.battle_name = _get_battle_name(self)
		elseif loser_military_force.is_in_fort then
			self.is_siege = true
			self.is_fort_siege = true
			if self.winner_is_attacker then
				self.winner_is_besieger = true
			end
			self.besieged_fort_name = loser_military_force.fort_in_name
			self.battle_name = _get_battle_name(self)
		end

		self.pre_battle_loser_military_forces[#self.pre_battle_loser_military_forces+1] = loser_military_force

		self.pre_battle_loser_soldiers = self.pre_battle_loser_soldiers + loser_military_force.num_of_soldiers
		self.pre_battle_loser_ships = self.pre_battle_loser_ships + loser_military_force.num_of_ships
		self.pre_battle_loser_units = self.pre_battle_loser_units + loser_military_force.num_of_units

		self.pre_battle_loser_ships_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_loser_ships_list[loser_military_force.faction_id], loser_military_force.ships)
		self.pre_battle_loser_units_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_loser_units_list[loser_military_force.faction_id], loser_military_force.units)

		self.pre_battle_soldiers = self.pre_battle_soldiers + self.pre_battle_loser_soldiers
		self.pre_battle_ships = self.pre_battle_ships + self.pre_battle_loser_ships
		self.pre_battle_units = self.pre_battle_units + self.pre_battle_loser_units

		self.pre_battle_ships_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_ships_list[loser_military_force.faction_id], self.pre_battle_loser_ships_list[loser_military_force.faction_id])
		self.pre_battle_units_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_units_list[loser_military_force.faction_id], self.pre_battle_loser_units_list[loser_military_force.faction_id])
	else
		mach_lib.update_mach_lua_log('Post-Battle loser')
		self.post_battle_loser_military_forces[#self.post_battle_loser_military_forces+1] = loser_military_force

		self.post_battle_loser_soldiers = self.post_battle_loser_soldiers + loser_military_force.num_of_soldiers
		self.post_battle_loser_ships = self.post_battle_loser_ships + loser_military_force.num_of_ships
		self.post_battle_loser_units = self.post_battle_loser_units + loser_military_force.num_of_units

		self.post_battle_loser_ships_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_loser_ships_list[loser_military_force.faction_id], loser_military_force.ships)
		self.post_battle_loser_units_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_loser_units_list[loser_military_force.faction_id], loser_military_force.units)

		self.post_battle_soldiers = self.post_battle_soldiers + self.post_battle_loser_soldiers
		self.post_battle_ships = self.post_battle_ships + self.post_battle_loser_ships
		self.post_battle_units = self.post_battle_units + self.post_battle_loser_units

		self.post_battle_ships_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_ships_list[loser_military_force.faction_id], self.post_battle_loser_ships_list[loser_military_force.faction_id])
		self.post_battle_units_list[loser_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_units_list[loser_military_force.faction_id], self.post_battle_loser_units_list[loser_military_force.faction_id])
	end

	self.loser_soldier_casualties = self.pre_battle_loser_soldiers - self.post_battle_loser_soldiers
	self.loser_ship_casualties = self.pre_battle_loser_ships - self.post_battle_loser_ships
	self.loser_unit_casualties = self.pre_battle_loser_units - self.post_battle_loser_units

	self.loser_commander_casualties_list = {}
	for pre_battle_military_force_idx, pre_battle_military_force in pairs(self.pre_battle_loser_military_forces) do
		self.loser_commander_casualties_list[pre_battle_military_force.faction_id] = self.loser_commander_casualties_list[pre_battle_military_force.faction_id] or {}
		local commander_found = false
		for post_battle_military_force_idx, post_battle_military_force in pairs(self.post_battle_loser_military_forces) do
			if post_battle_military_force.num_of_units == 0 and post_battle_military_force.num_of_ships == 0 then
				break
			elseif pre_battle_military_force.commander_type_and_name == post_battle_military_force.commander_type_and_name then
				commander_found = true
				mach_lib.update_mach_lua_log(string.format('Loser commander not killed in battle: %s', pre_battle_military_force.commander_type_and_name))
			end
		end
		if not commander_found then
			mach_lib.update_mach_lua_log(string.format('Loser commander killed in battle: %s', pre_battle_military_force.commander_type_and_name))
			self.loser_commander_casualties_list[pre_battle_military_force.faction_id][#self.loser_commander_casualties_list[pre_battle_military_force.faction_id]+1] = pre_battle_military_force.commander_type_and_name
		end
	end
	self.loser_ship_casualties_list =  _subtract_unit_tables_in_faction_keys(self.pre_battle_loser_ships_list, self.post_battle_loser_ships_list)
	self.loser_unit_casualties_list =  _subtract_unit_tables_in_faction_keys(self.pre_battle_loser_units_list, self.post_battle_loser_units_list)

	self.total_soldier_casualties = self.pre_battle_soldiers - self.post_battle_soldiers

--	mach_lib.update_mach_lua_log('gibberish')
--	mach_lib.update_mach_lua_log(self.pre_battle_ships)
--	mach_lib.update_mach_lua_log(self.post_battle_ships)

	self.total_ship_casualties = self.pre_battle_ships - self.post_battle_ships
	self.total_unit_casualties = self.pre_battle_units - self.post_battle_units
	self.total_ship_casualties_list = _subtract_unit_tables_in_faction_keys(self.pre_battle_ships_list, self.post_battle_ships_list)
	self.total_unit_casualties_list = _subtract_unit_tables_in_faction_keys(self.pre_battle_units_list, self.post_battle_units_list)
	mach_lib.update_unit_id_to_unit_unique_ids_list_with_casualties(self.total_ship_casualties_list)
	mach_lib.update_unit_id_to_unit_unique_ids_list_with_casualties(self.total_unit_casualties_list)

	self.is_naval_battle = self.is_naval_battle or loser_military_force.is_naval

	self.is_major_battle = _is_major_battle(self)

	mach_lib.update_mach_lua_log(string.format('Finished adding loser military force to Battle object of "%s" units and "%s" ships under command of "%s" of "%s" and is_pre_battle "%s".', loser_military_force.num_of_units, loser_military_force.num_of_ships, loser_military_force.commander_name, loser_military_force.faction_id, tostring(is_pre_battle)))
end


function Battle:add_winner_military_force (winner_military_force, is_pre_battle, is_attacker)
	mach_lib.update_mach_lua_log(string.format('Adding winner military force to Battle object of "%s" units and "%s" ships under command of "%s" of "%s" and is_pre_battle "%s".', winner_military_force.num_of_units, winner_military_force.num_of_ships, winner_military_force.commander_name, winner_military_force.faction_id, tostring(is_pre_battle)))

	self.pre_battle_ships_list[winner_military_force.faction_id] = self.pre_battle_ships_list[winner_military_force.faction_id] or {}
	self.pre_battle_winner_ships_list[winner_military_force.faction_id] = self.pre_battle_winner_ships_list[winner_military_force.faction_id] or {}
	self.post_battle_ships_list[winner_military_force.faction_id] = self.post_battle_ships_list[winner_military_force.faction_id] or {}
	self.post_battle_winner_ships_list[winner_military_force.faction_id] = self.post_battle_winner_ships_list[winner_military_force.faction_id] or {}
	self.winner_ship_casualties_list[winner_military_force.faction_id] = self.winner_ship_casualties_list[winner_military_force.faction_id] or {}
	self.total_ship_casualties_list[winner_military_force.faction_id] = self.total_ship_casualties_list[winner_military_force.faction_id] or {}

	self.pre_battle_units_list[winner_military_force.faction_id] = self.pre_battle_units_list[winner_military_force.faction_id] or {}
	self.pre_battle_winner_units_list[winner_military_force.faction_id] = self.pre_battle_winner_units_list[winner_military_force.faction_id] or {}
	self.post_battle_units_list[winner_military_force.faction_id] = self.post_battle_units_list[winner_military_force.faction_id] or {}
	self.post_battle_winner_units_list[winner_military_force.faction_id] = self.post_battle_winner_units_list[winner_military_force.faction_id] or {}
	self.winner_unit_casualties_list[winner_military_force.faction_id] = self.winner_unit_casualties_list[winner_military_force.faction_id] or {}
	self.total_unit_casualties_list[winner_military_force.faction_id] = self.total_unit_casualties_list[winner_military_force.faction_id] or {}

	if mach_lib.__player_faction_id__ == winner_military_force.faction_id then
		self.is_player_battle = true
	end

	if #self.attacker_faction_ids > 0 then
		is_attacker = is_attacker or false
	else
		is_attacker = is_attacker or true
	end

	if is_attacker then
		self.winner_is_attacker = true
		self.attacker_faction_ids = mach_lib.update_numbered_list(self.attacker_faction_ids, winner_military_force.faction_id)
		self.attacker_culture = self.attacker_culture or winner_military_force.culture
		self.attacker_nationality = self.attacker_nationality or winner_military_force.nationality
	else
		self.winner_is_attacker = false
		self.defender_faction_ids = mach_lib.update_numbered_list(self.defender_faction_ids, winner_military_force.faction_id)
		self.defender_culture = self.defender_culture or winner_military_force.culture
		self.defender_nationality = self.defender_nationality or winner_military_force.nationality
	end

	if #self.pre_battle_winner_military_forces == 0 and is_pre_battle then

	elseif not is_pre_battle and #self.post_battle_winner_military_forces == 0 then
		self.pos_x = winner_military_force.pos_x
		self.pos_y = winner_military_force.pos_y
		self.location = winner_military_force.location
		self.winner_culture = self.winner_culture or winner_military_force.culture
		self.winner_nationality = self.winner_nationality or winner_military_force.nationality
		self.battle_name = _get_battle_name(self)
	end

	self.winner_faction_ids = mach_lib.update_numbered_list(self.winner_faction_ids, winner_military_force.faction_id)
	self.winner_commander_names = mach_lib.update_numbered_list(self.winner_commander_names, winner_military_force.commander_type_and_name)
	self.winner_full_commander_names = mach_lib.update_numbered_list(self.winner_full_commander_names, winner_military_force.commander_nationality_and_type_and_name)

	if is_pre_battle then
		mach_lib.update_mach_lua_log('Pre-Battle winner')

		self.pre_battle_winner_military_forces[#self.pre_battle_winner_military_forces+1] = winner_military_force

		self.pre_battle_winner_soldiers = self.pre_battle_winner_soldiers + winner_military_force.num_of_soldiers
		self.pre_battle_winner_ships = self.pre_battle_winner_ships + winner_military_force.num_of_ships
		self.pre_battle_winner_units = self.pre_battle_winner_units + winner_military_force.num_of_units

		self.pre_battle_winner_ships_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_winner_ships_list[winner_military_force.faction_id], winner_military_force.ships)
		self.pre_battle_winner_units_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_winner_units_list[winner_military_force.faction_id], winner_military_force.units)

		self.pre_battle_soldiers = self.pre_battle_soldiers + self.pre_battle_winner_soldiers
		self.pre_battle_ships = self.pre_battle_ships + self.pre_battle_winner_ships
		self.pre_battle_units = self.pre_battle_units + self.pre_battle_winner_units

		self.pre_battle_ships_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_ships_list[winner_military_force.faction_id], self.pre_battle_winner_ships_list[winner_military_force.faction_id])
		self.pre_battle_units_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.pre_battle_units_list[winner_military_force.faction_id], self.pre_battle_winner_units_list[winner_military_force.faction_id])
	else
		mach_lib.update_mach_lua_log('Post-Battle winner')

		if winner_military_force.is_in_settlement then
			self.is_siege = true
			self.is_settlement_siege = true
			if not self.winner_is_attacker then
				self.winner_is_besieger = false
			end
			self.besieged_settlement_id = winner_military_force.settlement_in_id
			self.besieged_settlement_name = winner_military_force.settlement_in_name
			self.battle_name = _get_battle_name(self)
		elseif winner_military_force.is_in_fort then
			self.is_siege = true
			self.is_fort_siege = true
			if not self.winner_is_attacker then
				self.winner_is_besieger = false
			end
			self.besieged_fort_name = winner_military_force.fort_in_name
			self.battle_name = _get_battle_name(self)
		end

		self.post_battle_winner_military_forces[#self.post_battle_winner_military_forces+1] = winner_military_force

		self.post_battle_winner_soldiers = self.post_battle_winner_soldiers + winner_military_force.num_of_soldiers
		self.post_battle_winner_ships = self.post_battle_winner_ships + winner_military_force.num_of_ships
		self.post_battle_winner_units = self.post_battle_winner_units + winner_military_force.num_of_units

		self.post_battle_winner_ships_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_winner_ships_list[winner_military_force.faction_id], winner_military_force.ships)
		self.post_battle_winner_units_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_winner_units_list[winner_military_force.faction_id], winner_military_force.units)

		self.post_battle_soldiers = self.post_battle_soldiers + self.post_battle_winner_soldiers
		self.post_battle_ships = self.post_battle_ships + self.post_battle_winner_ships
		self.post_battle_units = self.post_battle_units + self.post_battle_winner_units

		self.post_battle_ships_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_ships_list[winner_military_force.faction_id], self.post_battle_winner_ships_list[winner_military_force.faction_id])
		self.post_battle_units_list[winner_military_force.faction_id] = mach_lib.concat_tables(self.post_battle_units_list[winner_military_force.faction_id], self.post_battle_winner_units_list[winner_military_force.faction_id])

	end
	self.winner_soldier_casualties = self.pre_battle_winner_soldiers - self.post_battle_winner_soldiers
	self.winner_ship_casualties = self.pre_battle_winner_ships - self.post_battle_winner_ships
	self.winner_unit_casualties = self.pre_battle_winner_units - self.post_battle_winner_units

	self.winner_commander_casualties_list = {}
	for pre_battle_military_force_idx, pre_battle_military_force in pairs(self.pre_battle_winner_military_forces) do
		self.winner_commander_casualties_list[pre_battle_military_force.faction_id] = self.winner_commander_casualties_list[pre_battle_military_force.faction_id] or {}
		local commander_found = false
		for post_battle_military_force_idx, post_battle_military_force in pairs(self.post_battle_winner_military_forces) do
			if post_battle_military_force.num_of_units == 0 and post_battle_military_force.num_of_ships == 0 then
				break
			elseif pre_battle_military_force.commander_type_and_name == post_battle_military_force.commander_type_and_name then
				commander_found = true
				mach_lib.update_mach_lua_log(string.format('Winner commander not killed in battle: %s', pre_battle_military_force.commander_type_and_name))
			end
		end
		if not commander_found then
			mach_lib.update_mach_lua_log(string.format('Winner commander killed in battle: %s', pre_battle_military_force.commander_type_and_name))
			self.winner_commander_casualties_list[pre_battle_military_force.faction_id][#self.winner_commander_casualties_list[pre_battle_military_force.faction_id]+1] = pre_battle_military_force.commander_type_and_name
		end
	end

	self.winner_unit_casualties_list =  _subtract_unit_tables_in_faction_keys(self.pre_battle_winner_units_list, self.post_battle_winner_units_list)
	self.winner_ship_casualties_list =  _subtract_unit_tables_in_faction_keys(self.pre_battle_winner_ships_list, self.post_battle_winner_ships_list)

	self.total_soldier_casualties = self.pre_battle_soldiers - self.post_battle_soldiers

	mach_lib.update_mach_lua_log('gibberish1')
	mach_lib.update_mach_lua_log(self.pre_battle_ships)
	mach_lib.update_mach_lua_log(self.post_battle_ships)

	self.total_ship_casualties = self.pre_battle_ships - self.post_battle_ships
	self.total_unit_casualties = self.pre_battle_units - self.post_battle_units
	self.total_ship_casualties_list =  _subtract_unit_tables_in_faction_keys(self.pre_battle_ships_list, self.post_battle_ships_list)
	self.total_unit_casualties_list =  _subtract_unit_tables_in_faction_keys(self.pre_battle_units_list, self.post_battle_units_list)
	mach_lib.update_unit_id_to_unit_unique_ids_list_with_casualties(self.total_ship_casualties_list)
	mach_lib.update_unit_id_to_unit_unique_ids_list_with_casualties(self.total_unit_casualties_list)

	self.is_naval_battle = self.is_naval_battle or winner_military_force.is_naval
	if self.is_naval_battle then
		self.winner_ship_prizes_list = _get_ship_captured_list(self.pre_battle_winner_ships_list, self.post_battle_winner_ships_list)
		self.winner_ship_prizes = #self.winner_ship_prizes_list
		self.loser_ship_captured_list = self.winner_ship_prizes_list
		self.loser_ship_captured = #self.loser_ship_captured_list
	end
	self.is_major_battle = _is_major_battle(self)
	mach_lib.update_mach_lua_log(string.format('Finished adding winner military force to Battle object of "%s" units and "%s" ships under command of "%s" of "%s" and is_pre_battle "%s".', winner_military_force.num_of_units, winner_military_force.num_of_ships, winner_military_force.commander_name, winner_military_force.faction_id, tostring(is_pre_battle)))
end


--MilitaryForce class
MilitaryForce = {}
MilitaryForce.__index = MilitaryForce
function MilitaryForce:new (character_details, faction_id, character_context)
	mach_lib.update_mach_lua_log("Initializing Military Force for faction id: "..tostring(faction_id))
	faction_id = faction_id or nil
	character_context = character_context or nil
    local self = setmetatable(
		{
			action_points_per_turn = 0;
			address = nil;
			commander_name = nil;
			name = nil;
			commander_type_id = 0;
			commander_type = nil;
			commander_type_and_name = nil;
			commander_nationality_and_type_and_name = nil;
			location = nil;
			contained_entities = {};
			units = {};
			ships = {};
			num_of_soldiers = 0;
			num_of_units = 0;
			num_of_ships = 0;
			faction_id = nil;
			faction_name = nil;
			is_naval = nil;
			obj = character_details or nil;
			out_of_supply = false;
			pos_x = 0;
			pos_y = 0;
			culture = nil;
			nationality = nil;
			character_context = nil;
			is_rebel = nil;
		},
		MilitaryForce
	)
	mach_lib.update_mach_lua_log("Finished declaring variables.")

	if character_details then
		self.action_points_per_turn = character_details.ActionPointsPerTurn
		self.address = character_details.Address
		self.commander_name = character_details.Name
		self.name = character_details.Name
		self.faction_id = faction_id or mach_lib.get_faction_id_from_character_address(character_details.Address)
		self.faction_name = mach_lib.get_faction_screen_name_from_faction_id(self.faction_id)
		self.nationality = mach_lib.get_nationality_from_faction_id(self.faction_id)
        self.commander_type_id = character_details.CommanderType
		self.commander_type = character_details.AgentType
		self.commander_type_and_name = self.commander_type..' '..self.name
		self.commander_nationality_and_type_and_name = self.nationality..' '..self.commander_type_and_name
		self.location = character_details.Location
		self.contained_entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(character_details.Address, character_details.Address)
		self.is_naval = character_details.IsNaval
		self.pos_x = character_details.PosX
		self.pos_y = character_details.PosY

		if character_details["InfoImage"] ~= '' then
			local info_image = character_details['InfoImage']
			self.culture = string.gsub(string.gsub(info_image, "data/ui/portraits/", ""), "/.*","")
		end
		if not self.is_naval then
			self.num_of_soldiers = character_details.Soldiers
			self.num_of_units = character_details.Units
		else
			if self.contained_entities.Units then
				self.num_of_units = #self.contained_entities.Units
			end
			for _, contained_ship_details in pairs(self.contained_entities.Ships) do
				local military_unit = MilitaryUnit:new(self, contained_ship_details)
				self.ships[military_unit.unit_id] = military_unit
			end
			self.num_of_ships = mach_lib.get_num_of_elements_in_table(self.ships)
		end

		if self.contained_entities.Units then
			for _, contained_unit_details in pairs(self.contained_entities.Units) do
				local military_unit = MilitaryUnit:new(self, contained_unit_details)
				self.units[military_unit.unit_id] = military_unit
				if self.is_naval and not military_unit.is_naval then
					self.num_of_soldiers = self.num_of_soldiers + military_unit.men
				end
			end
		end
	elseif character_context then
		self.commander_name = mach_lib.get_character_full_name_from_character_context(character_context)
		self.name = self.commander_name
		local region_id = mach_lib.get_character_region_from_character_context(character_context)
        self.location = mach_lib.convert_str_to_title_case(region_id)
		self.faction_id = faction_id or mach_lib.get_faction_id_from_context(character_context, 'CharacterSelected')
		self.faction_name = mach_lib.get_faction_screen_name_from_faction_id(self.faction_id)
		self.nationality = mach_lib.get_nationality_from_faction_id(self.faction_id, region_id)
		self.commander_type = mach_lib.get_character_type_from_character_context(character_context)
		self.commander_type_and_name = self.commander_type..' '..self.commander_name
		self.commander_nationality_and_type_and_name = self.nationality..' '..self.commander_type_and_name
        self.is_naval = self.commander_type == 'Admiral' or self.commander_type == 'Captain'
		self.culture = mach_lib.get_character_culture_from_character_context(character_context)
		self.pos_x = mach_data.region_capital_coord_list[region_id][1] or 0
		self.pos_y = mach_data.region_capital_coord_list[region_id][2] or 0
		self.character_context = character_context
	end
	self.is_rebel = string.find(self.faction_id, 'rebels')

	mach_lib.update_mach_lua_log(string.format('Finished initializing military force of "%s" under command of "%s"', self.faction_id, self.commander_name))
	return self
end


--MilitaryUnit class
MilitaryUnit = {}
MilitaryUnit.__index = MilitaryUnit
function MilitaryUnit:new (military_force, unit_details, unit_context)
	mach_lib.update_mach_lua_log("Initializing Military Unit for faction id: "..tostring(military_force.faction_id))
	unit_context = unit_context or nil
	local self = setmetatable(
		{
			action_points = unit_details.ActionPoints;
			address = unit_details.Address;
			unit_name = unit_details.Name;
			regiment_name = unit_details.RegimentName;
			unit_id = unit_details.Id;
			unit_unique_id = mach_lib.get_latest_unit_unique_id_from_unit_id(unit_details.Id);
			location = military_force.location;
			pos_x = military_force.pos_x;
			pos_y = military_force.pos_y;
			icon = unit_details.Icon;
			replenished = unit_details.Replenished;
			men = unit_details.Men;
			unit_scale = unit_details.UnitScale;
			experience = nil;
			ammunition = unit_details.Ammunition;
			guns = unit_details.Guns;
			is_naval = unit_details.IsNaval;
			is_artillery = unit_details.IsArtillery;
			is_fixed_artillery = unit_details.IsFixedArtillery;
			unit_record = unit_details.UnitRecord;
			obj = unit_details;
			faction_name = military_force.faction_name;
			faction_id = military_force.faction_id;
			culture = military_force.culture;
			nationality = military_force.nationality;
			is_rebel = military_force.is_rebel;
			military_force_address = military_force.address;
			character_address = unit_details.CharacterPtr;
			commander_name = unit_details.CommandersName;
			commander_type_id = unit_details.CommanderType;
		},
		MilitaryUnit
	)

	if not mach_data.__unit_id_to_unit_unique_ids__[self.unit_id] then
		mach_data.__unit_id_to_unit_unique_ids__[self.unit_id] = {}
		mach_data.__unit_id_to_unit_unique_ids__[self.unit_id][#mach_data.__unit_id_to_unit_unique_ids__[self.unit_id]] = self.unit_unique_id
	end

	if self.unit_scale ~= nil then
		self.experience = unit_details.RecruitmentInfo.Experience
	else
		self.experience = unit_details.Experience
	end

	mach_lib.update_mach_lua_log("Finished declaring variables for military unit.")
	mach_lib.update_mach_lua_log(string.format('Finished initializing military unit "%s" of "%s" under command of "%s"', self.unit_name, self.faction_id, self.commander_name))
	return self
end


--Navy class
Navy = setmetatable({}, {__index = MilitaryForce})
Navy.__index = Navy
function Navy:new (character_details, faction_id, character_context)
	mach_lib.update_mach_lua_log("Initializing Navy.")
	faction_id = faction_id or nil
	character_context = character_context or nil
	local self = setmetatable(MilitaryForce:new(character_details, faction_id, character_context), Navy)
	self.num_of_sailors = 0
    self.num_of_ship_guns = 0
	self.supplied_armies = {}
	for _, ship in pairs(self.ships) do
		self.num_of_sailors = self.num_of_sailors + ship.men
		self.num_of_ship_guns = self.num_of_ship_guns + ship.guns
	end

    mach_lib.update_mach_lua_log(string.format('Finished initializing navy of "%s" under command of "%s"', self.faction_id, self.commander_name))
    return self
end


--Region class
Region = {}
Region.__index = Region
function Region:new (region_details, faction_id)
	mach_lib.update_mach_lua_log(string.format('Initializing Region of faction_id "%s"',  tostring(faction_id)))
	local self = setmetatable(
		{
			address = region_details.Address;
			name = region_details.Name;
			settlement_name = region_details.Settlement;
			owned_by_protectorate = region_details.OwnedByProtectorate;
			region_id = mach_lib.get_region_id_from_region_address(region_details.Address);
			faction_name = mach_lib.get_faction_screen_name_from_faction_id(faction_id);
			faction_id = faction_id;
			pos_x = nil;
			pos_y = nil;
			capital_pos_x = nil;
			capital_pos_y = nil;
			obj = region_details;
			supplied_armies = {};
		},
		Region
	)

	if self.region_id ~= nil then
		self.capital_pos_x = mach_data.region_capital_coord_list[self.region_id][1]
		self.capital_pos_y = mach_data.region_capital_coord_list[self.region_id][2]
		if not pos_x and not pos_y then
			self.pos_x = self.capital_pos_x
			self.pos_y = self.capital_pos_y
		end
	end
	mach_lib.update_mach_lua_log(string.format('Finished initializing region of "%s" with region key "%s"', tostring(self.faction_id),
		tostring(self.region_id)))
	return self
end


function _get_battle_name(battle)
	mach_lib.update_mach_lua_log('Getting battle name for battle.')
	local battle_name_short = nil
	local battle_name = nil
	if not battle.is_settlement_siege and not battle.is_fort_siege then
		battle_name_short = string.format('Battle of %s', battle.location)
	elseif battle.is_settlement_siege then
		battle_name_short = string.format('Battle of %s', battle.besieged_settlement_name)
	else
		battle_name_short = string.format('Battle of %s', battle.besieged_fort_name)
	end
	battle_name = string.format('%s %s (%s)', mach_lib.convert_str_to_title_case(mach_data.ordinal_num_list[_get_number_of_battles_with_same_name(battle_name_short) + 1]), battle_name_short, mach_lib.__current_year__)
	mach_lib.update_mach_lua_log(string.format('Finished getting battle name for battle: "%s"', battle_name))
	return battle_name
end


function _get_number_of_battles_with_same_name(initial_battle_name)
	mach_lib.update_mach_lua_log(string.format('Getting number of battles with name: "%s"', initial_battle_name))
	local battles_with_name = {}
	for battle_idx = 1, #mach_data.__battles_list__ do
		local battle = mach_data.__battles_list__[battle_idx]
		if string.find(battle.battle_name, initial_battle_name) then
			battles_with_name[#battles_with_name+1] = battle
		end
	end
	mach_lib.update_mach_lua_log(string.format('Finished getting number of battles with name "%s". Total number "%s"', initial_battle_name, #battles_with_name))
	return #battles_with_name
end


function _get_ship_captured_list(pre_battle_faction_ships_list, post_battle_faction_ships_list)
	mach_lib.update_mach_lua_log(string.format('Getting ships captured list.'))
	local ship_captured_list = {}
	local found = false
	mach_lib.update_mach_lua_log(string.format('test'))
	for post_battle_faction_key, post_battle_faction_ships_list in pairs(post_battle_faction_ships_list) do
		mach_lib.update_mach_lua_log(string.format(post_battle_faction_key))
		for post_battle_ship_idx, post_battle_ship in pairs(post_battle_faction_ships_list) do
			for pre_battle_faction_key, pre_battle_faction_ships_list in pairs(pre_battle_faction_ships_list) do
				mach_lib.update_mach_lua_log(string.format(pre_battle_faction_key))
				for pre_battle_ship_idx, pre_battle_ship in pairs(pre_battle_faction_ships_list) do
					if post_battle_ship.unit_id == pre_battle_ship.unit_id then
						found = true
						break
					end
				end
				if found then
					break
				end
			end
			if not found then
				ship_captured_list[post_battle_faction_key] = post_battle_ship
			end
		end
	end
	mach_lib.update_mach_lua_log(string.format('Finished getting ships captured list. %s ships captured.', #ship_captured_list))
	return ship_captured_list
end


function _is_major_battle(battle)
	mach_lib.update_mach_lua_log('Determining if battle is a "Major Battle".')
	local is_major_battle = nil
	local rebels_are_losers = false
	local total_loser_factions_number_of_soldiers = 0
	local total_loser_factions_number_of_ships = 0
	for loser_faction_ids_idx = 1, #battle.loser_faction_ids do
		local loser_faction_id = battle.loser_faction_ids[loser_faction_ids_idx]
		mach_lib.update_mach_lua_log(string.format('loser faction id: "%s"', loser_faction_id))
		if loser_faction_id == 'rebels' then
			rebels_are_losers = true
		end

		if not battle.is_naval_battle then
			total_loser_factions_number_of_soldiers = total_loser_factions_number_of_soldiers + mach_lib.get_faction_num_of_soldiers(loser_faction_id)
		else
			total_loser_factions_number_of_ships = total_loser_factions_number_of_ships + mach_lib.get_faction_num_of_ships(loser_faction_id)
		end
	end

	if rebels_are_losers == true and not (battle.is_siege and battle.winner_is_attacker) then
		mach_lib.update_mach_lua_log('Battle loser was "rebels", and not a siege and attacker is winner. Not a major battle.')
		is_major_battle = false
	elseif (battle.is_siege and battle.winner_is_besieger) then
		mach_lib.update_mach_lua_log('Battle is a siege and winner is besieger. A major battle.')
		is_major_battle = true
		mach_lib.update_mach_lua_log('Battle is a "Major Battle"!')
	elseif (not battle.is_naval_battle and
			(battle.total_soldier_casualties >= mach_config.__MACH_MAJOR_BATTLE_MIN_TOTAL_SOLDIER_CASUALTIES__ * mach_lib.__unit_scale_factor__ and
			battle.loser_soldier_casualties >= (total_loser_factions_number_of_soldiers + battle.loser_soldier_casualties) * mach_config.__MACH_MAJOR_BATTLE_MIN_PERCENTAGE_OF_TOTAL_LOSER_FORCES_AS_CASUALTIES__ * mach_lib.__unit_scale_factor__)) then
		mach_lib.update_mach_lua_log(string.format('Battle is not a naval battle. Total soldier casualties "%s" >= "%s" * "%s", and total loser solider casualties "%s" are >= total loser factions number of soldiers "%s" + "%s" * "%s" * unit scale factor "%s". A major battle.', battle.total_soldier_casualties, mach_config.__MACH_MAJOR_BATTLE_MIN_TOTAL_SOLDIER_CASUALTIES__, tostring(mach_lib.__unit_scale_factor__), battle.loser_soldier_casualties, total_loser_factions_number_of_soldiers, battle.loser_soldier_casualties, tostring(mach_config.__MACH_MAJOR_BATTLE_MIN_PERCENTAGE_OF_TOTAL_LOSER_FORCES_AS_CASUALTIES__), tostring(mach_lib.__unit_scale_factor__)))
		is_major_battle = true
		mach_lib.update_mach_lua_log('Battle is a "Major Battle"!')
	elseif (battle.is_naval_battle and
					(battle.total_ship_casualties >= mach_config.__MACH_MAJOR_BATTLE_MIN_TOTAL_SHIP_CASUALTIES__ and
							((battle.loser_ship_casualties >= (total_loser_factions_number_of_ships + battle.loser_ship_casualties) * mach_config.__MACH_MAJOR_BATTLE_MIN_PERCENTAGE_OF_TOTAL_LOSER_FORCES_AS_CASUALTIES__) or
					(battle.loser_unit_casualties >= mach_config.__MACH_MAJOR_BATTLE_MIN_LAND_UNIT_ON_SHIP_CASUALTIES__)))) then
		mach_lib.update_mach_lua_log('testsadfasdf')
		mach_lib.update_mach_lua_log(string.format('Battle is a naval battle. Total ship casualties "%s" >= "%s", and loser ship casualties "%s" are >= total loser factions number of ships "%s" + "%s" * "%s", or loser unit casualties "%s" >= "%s". A major battle.', battle.total_ship_casualties, mach_config.__MACH_MAJOR_BATTLE_MIN_TOTAL_SHIP_CASUALTIES__, battle.loser_ship_casualties, total_loser_factions_number_of_ships, battle.loser_ship_casualties, tostring(mach_config.__MACH_MAJOR_BATTLE_MIN_PERCENTAGE_OF_TOTAL_LOSER_FORCES_AS_CASUALTIES__), battle.loser_unit_casualties, tostring(mach_lib.__MACH_MAJOR_BATTLE_MIN_LAND_UNIT_ON_SHIP_CASUALTIES__)))
		is_major_battle = true
		mach_lib.update_mach_lua_log('Battle is a "Major Battle"!')
	else
		is_major_battle = false
		mach_lib.update_mach_lua_log('Battle is NOT a "Major Battle".')
	end
	mach_lib.update_mach_lua_log('Finished determining if battle is a "Major Battle".')
	return is_major_battle
end


function _subtract_unit_tables_in_faction_keys(t1, t2)
	mach_lib.update_mach_lua_log(string.format("Subtracting two unit tables in faction keys with element counts t1=%s and t2=%s.", mach_lib.get_num_of_elements_in_table(t1), mach_lib.get_num_of_elements_in_table(t2)))
	local result_table = mach_lib.copy_table(t1)
	local result_table_unit_count = 0
	for t1_key, t1_value in pairs(t1) do
		for t2_key, t2_value in pairs(t2) do
			mach_lib.update_mach_lua_log(string.format('t1_key %s', t1_key))
			mach_lib.update_mach_lua_log(string.format('t2_key %s', t2_key))
			if t1_key == t2_key then
				if type(t1_value) == "table" and type(t2_value) == "table" then
					mach_lib.update_mach_lua_log(string.format("Element counts t1=%s and t2=%s.", mach_lib.get_num_of_elements_in_table(t1_value), mach_lib.get_num_of_elements_in_table(t2_value)))
					for t1_key_2, t1_value_2 in pairs(t1_value) do
						for t2_key_2, t2_value_2 in pairs(t2_value) do
							if t1_value_2.unit_id == t2_value_2.unit_id then
								result_table[t1_key][t1_key_2] = nil
							end
						end
					end
				end
			end
			result_table_unit_count = result_table_unit_count + mach_lib.get_num_of_elements_in_table(result_table[t1_key])
		end
	end
	mach_lib.update_mach_lua_log(string.format("Finished subtracting two unit tables in faction keys, result table element count %s", result_table_unit_count))
	return result_table
end




