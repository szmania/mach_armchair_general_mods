module(..., package.seeall)

mach = require "WALI/mach"
mach_lib = require "WALI/mach_lib"
mach_data = require "WALI/mach_data"
mach_classes = require "WALI/mach_classes"


function mach_battle_chronicler()
	mach_lib.update_mach_lua_log("Activating Machiavelli's \"Battle Chronicler\"")

    mach.__mach_features_enabled__[#mach.__mach_features_enabled__+1] = "MACH Battle Chronicler"
    local __current_battle__ = nil
    local __winner_unit_seen__ = false
    local __loser_unit_seen__ = false
    local __rebel_character_completed_battle__ = false
    local __entity_lists_panel_opened__ = false
    local __regions_tab_opened__ = false
    local __regions_tab_tooltip__
    local __regions_column_header_tooltip__
    local __population_column_header_tooltip__
    local __public_order_column_header_tooltip__
    local __income_column_header_tooltip__


    function _finish_processing_battle()
        mach_lib.update_mach_lua_log('Finishing processing battle tear down started.')
        if __winner_unit_seen__ == true then
            mach_lib.update_mach_lua_log('Battle winner unit seen.')
            if __loser_unit_seen__ == false then
                mach_lib.update_mach_lua_log('Battle losers not seen, getting post battle all factions forces to find losers.')
                local post_battle_all_factions_military_forces_list = mach_lib.get_all_factions_military_forces()
                local pre_battle_loser_military_forces, post_battle_loser_military_forces = _get_pre_and_post_battle_loser_military_forces(__current_battle__.pre_battle_winner_military_forces[1], mach_data.__all_factions_military_forces_list__, post_battle_all_factions_military_forces_list)
                assert(pre_battle_loser_military_forces and post_battle_loser_military_forces, mach_lib.update_mach_lua_log('ERROR: Unable to find battle losers after going through all factions forces!'))
                for pre_battle_loser_military_forces_idx = 1, #pre_battle_loser_military_forces do
                    local pre_battle_loser_military_force = pre_battle_loser_military_forces[pre_battle_loser_military_forces_idx]
                end
                for post_battle_loser_military_forces_idx = 1, #post_battle_loser_military_forces do
                    local post_battle_loser_military_force = post_battle_loser_military_forces[post_battle_loser_military_forces_idx]
                    __current_battle__:add_loser_military_force(post_battle_loser_military_force, false)
                end
            end

            __winner_unit_seen__ = false
            __loser_unit_seen__ = false
            __rebel_character_completed_battle__ = false

            _show_battle_message_box(__current_battle__)

            mach_data.__battles_list__[#mach_data.__battles_list__+1] = __current_battle__

            for participant_faction_id, participant_faction_id in pairs(mach_lib.concat_tables(__current_battle__.winner_faction_ids, __current_battle__.loser_faction_ids)) do
                mach_lib.update_mach_lua_log(participant_faction_id)
                mach_data.__all_factions_military_forces_list__[participant_faction_id] = mach_lib.get_faction_military_forces(participant_faction_id)
            end
            mach_lib.update_mach_lua_log("Finished processing battle.")
        else
            mach_lib.update_mach_lua_log(string.format('ERROR: Battle winners unit NOT seen! Cannot finish processing battle of unique id "%s"', __current_battle__.battle_unique_id))
        end
        __current_battle__ = nil
        mach_lib.update_mach_lua_log('Finishing processing battle tear down completed.')
    end


    function _get_battle_message_image(battle)
        mach_lib.update_mach_lua_log('Getting battle message image.')
        local image = nil
        if battle.is_naval_battle then
            if battle.is_major_battle then
                image = "data/ui/EventPics/european/naval loose.tga"
            else
                image = "data/ui/EventPics/european/naval_win.tga"
            end
        elseif battle.is_siege then
            local besieged_culture
            if battle.winner_is_besieger then
                besieged_culture = battle.loser_culture
            else
                besieged_culture = battle.winner_culture
            end
            if battle.is_settlement_siege then
                if besieged_culture == 'middle_east' or besieged_culture == 'indian' then
                    image = "data/ui/EventPics/middle_east/besieged-3asian.tga"
                elseif besieged_culture == 'tribal' then
                    image = "data/ui/EventPics/tribal_playable/nat_captured.tga"
                else
                    image = "data/ui/EventPics/european/besieged-3.tga"
                end
            else
                if besieged_culture == 'middle_east' or besieged_culture == 'indian' then
                    image = "data/ui/EventPics/middle_east/besieged-asian-fort.tga"
                elseif besieged_culture == 'tribal' then
                    image = "data/ui/EventPics/tribal_playable/nat_captured.tga"
                else
                    image = "data/ui/EventPics/european/besieged-fort.tga"
                end
            end
        else
            if battle.winner_culture == 'middle_east' or battle.winner_culture == 'indian' then
                image = "data/ui/EventPics/middle_east/afterbatle ottoman.tga"
            elseif battle.winner_culture == 'tribal' then
                image = "data/ui/EventPics/tribal_playable/nat_afterbatle.tga"
            else
                image = "data/ui/EventPics/european/afterbatle eu.tga"
            end
        end
        mach_lib.update_mach_lua_log(string.format('Battle message image gotten: "%s"', image))
        return image
    end


    function _get_battle_message_title_and_text(battle)
        mach_lib.update_mach_lua_log('Getting battle message text.')
        local title = "A battle has occurred:"
        local major_str = ''
        if battle.is_major_battle then
            title = "A major battle has taken place:"
            major_str = "major "
        end
        title = title..'\nThe '..battle.battle_name

        local winner_faction_names_str = mach_lib.get_battle_faction_names_str(battle.winner_faction_ids)
        if winner_faction_names_str == 'Rebels' then
            battle.winner_faction_ids = {'rebels'}
        end
        local winner_commander_names_str = _get_commander_names_str(battle.winner_full_commander_names)
        local loser_faction_names_str = mach_lib.get_battle_faction_names_str(battle.loser_faction_ids)
        if loser_faction_names_str == 'Rebels' then
            battle.loser_faction_ids = {'rebels'}
        end
        local loser_commander_names_str = _get_commander_names_str(battle.loser_full_commander_names)

        local text = ''
        if not battle.is_siege then
            mach_lib.update_mach_lua_log('testing 1')
            text = string.format('The %s: \n\nWe have received a message from a courier telling us of a %sbattle that has taken place in %s.', battle.battle_name, major_str, battle.location)
        else
            mach_lib.update_mach_lua_log('testing 2')
            mach_lib.update_mach_lua_log(battle.battle_name)
            mach_lib.update_mach_lua_log(major_str)
            mach_lib.update_mach_lua_log(battle.besieged_settlement_name)

            if battle.is_settlement_siege then
                text = string.format('The %s: \n\nWe have received a message from a courier telling us of a %sbattle that has occurred in and around the vicinity of %s.', battle.battle_name, major_str, battle.besieged_settlement_name)
                mach_lib.update_mach_lua_log('testing 2a')
                if battle.winner_is_besieger then
                    mach_lib.update_mach_lua_log('testing 2b')
                    text = text..string.format('\n\nThe city of %s has been captured after an assault on that city!', battle.besieged_settlement_name)
                else
                    mach_lib.update_mach_lua_log('testing 2c')
                    text = text..string.format('\n\nThe city of %s was under siege, but the siege has been lifted after a battle!', battle.besieged_settlement_name)
                end
            else
                text = string.format('The %s: \n\nWe have received a message from a courier telling us of a %sbattle that has occurred in and around the vicinity of %s.', battle.battle_name, major_str, battle.besieged_fort_name)
                mach_lib.update_mach_lua_log('testing 2d')
                if battle.winner_is_besieger then
                    mach_lib.update_mach_lua_log('testing 2e')
                    text = text..string.format('\n\n%s has been captured after an assault on that fort!', battle.besieged_fort_name)
                else
                    mach_lib.update_mach_lua_log('testing 2f')
                    text = text..string.format('\n\n%s was under siege, but the siege has been lifted after a battle!', battle.besieged_fort_name)
                end
            end
        end
        mach_lib.update_mach_lua_log('testing 3')
        local winner_details_str = _get_side_details_str(true, battle, winner_faction_names_str, winner_commander_names_str)
        text = text..winner_details_str
        text = text..'\n\nUnits and leaders lost by victors:'
        local winner_unit_details_str = _get_unit_details_str(true, false, battle)
        text = text..winner_unit_details_str
        if battle.is_naval_battle or mach_lib.is_value_in_table('MACH Capture Artillery', mach.__mach_features_enabled__) then
            local winner_unit_captured_details_str = _get_unit_details_str(true, true, battle)
            if winner_unit_captured_details_str ~= '' then
                text = text..'\n\nUnits captured by victors:'
                text = text..winner_unit_captured_details_str
            end
        end

        local loser_details_str = _get_side_details_str(false, battle, loser_faction_names_str, loser_commander_names_str)
        text = text..loser_details_str
        text = text..'\n\nUnits and leaders lost by losers:'
        local loser_unit_details_str = _get_unit_details_str(false, false, battle)
        text = text..loser_unit_details_str

        if not battle.is_naval_battle then
            text = text..string.format('\n\nTotal soldier casualties in this battle: %s \nTotal soldier(s) engaged in this battle: %s', battle.total_soldier_casualties, battle.pre_battle_soldiers)
        else
            text = text..string.format('\n\nTotal ship casualties in this battle: %s \nTotal ship(s) engaged in this battle: %s ', battle.total_ship_casualties, battle.pre_battle_ships)
            if battle.pre_battle_soldiers > 0 then
                text = text..string.format('\n\nTotal soldier casualties embarked on ship(s) in this battle: %s \nTotal soldier(s) embarked on ship(s) engaged in this battle: %s ', battle.total_soldier_casualties, battle.pre_battle_soldiers)
            end
        end
        mach_lib.update_mach_lua_log('Finished getting Battle message title and text.')
        return title, text
    end


    function _get_commander_names_str(commander_names)
        mach_lib.update_mach_lua_log('Getting commander names str from commander name list.')
        local commander_names_str = ''
        for commander_name_idx = 1, #commander_names do
            local commander_name = commander_names[commander_name_idx]
            if commander_name_idx == 1 then
                commander_names_str = commander_name
--            elseif commander_name_idx == #commander_names then
--                commander_names_str = commander_names_str.." and "..commander_name
            else
                commander_names_str = commander_names_str.." and "..commander_name
            end
        end
        if commander_names_str == '' then
            commander_names_str = 'an unknown commander'
        end

        mach_lib.update_mach_lua_log(string.format('Finished getting commander names str from commander name list: "%s"', commander_names_str))
        return commander_names_str
    end


    local function _get_moused_over_unit_card_unit_address()
        mach_lib.update_mach_lua_log(string.format('Getting moused over unit card unit address.'))
        local moused_over_unit_card_unit_address
        local g_cardgroup = UIComponent(mach_lib.__wali_m_root__:Find("UnitCardGroup"))
--        mach_lib.update_mach_lua_log(g_cardgroup)
        local unit_cards = g_cardgroup:LuaCall("Cards")
        --        mach_lib.output_table_to_mach_log(unit_cards,1)
        local utils = require("Utilities")
--        mach_lib.update_mach_lua_log('tard')

        for unit_cards_idx, unit_card in  pairs(unit_cards) do
--            mach_lib.update_mach_lua_log('drap')

--            mach_lib.update_mach_lua_log(unit_card)
            local unit_card_component = UIComponent(unit_card)
--            mach_lib.update_mach_lua_log(unit_card_component)

            local unit_card_unit_address = unit_card_component:LuaCall("ItemAddress")
--            mach_lib.update_mach_lua_log(unit_card_unit_address)
--
--            mach_lib.update_mach_lua_log(utils.Component.MouseOver())
            local mouse_over_unit_card_component = UIComponent(utils.Component.MouseOver())
--            mach_lib.update_mach_lua_log(mouse_over_unit_card_component)

            local mouse_over_unit_card_address = mouse_over_unit_card_component:LuaCall("ItemAddress")
--            mach_lib.update_mach_lua_log(mouse_over_unit_card_address)
--            mach_lib.update_mach_lua_log('drap1')

            if mouse_over_unit_card_address == unit_card_unit_address then
                moused_over_unit_card_unit_address = unit_card_unit_address
--                mach_lib.update_mach_lua_log(moused_over_unit_card_unit_address)
                break
            end
        end
        mach_lib.update_mach_lua_log(string.format('Finished getting moused over unit card unit address. Unit address: "%s"', tostring(moused_over_unit_card_unit_address)))
        return moused_over_unit_card_unit_address
    end


    function _get_pre_and_post_battle_loser_military_forces(pre_battle_winner_military_force, pre_battle_all_factions_military_forces_list, post_battle_all_factions_military_forces_list)
        mach_lib.update_mach_lua_log(string.format('Getting battle loser military forces for winner faction "%s"', pre_battle_winner_military_force.faction_id))
        mach_lib.update_mach_lua_log(pre_battle_winner_military_force.faction_id)
--        local diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(pre_battle_winner_military_force.faction_id)
        local pre_battle_loser_military_forces = {}
        local post_battle_loser_military_forces = {}
        local faction_ids_at_war_with_faction = mach_lib.get_faction_ids_at_war_with_faction_id(pre_battle_winner_military_force.faction_id)
        for _, enemy_faction_id in pairs(faction_ids_at_war_with_faction) do
            mach_lib.update_mach_lua_log(string.format('Searching as a possible battle opponent "%s" to battle won by "%s".', enemy_faction_id, pre_battle_winner_military_force.faction_id))

            mach_lib.update_mach_lua_log(assert(pre_battle_all_factions_military_forces_list[enemy_faction_id], string.format('ERROR: Faction id "%s" is not in table "pre_battle_all_factions_military_forces_list".', enemy_faction_id)))
            local pre_battle_enemy_military_forces = pre_battle_all_factions_military_forces_list[enemy_faction_id]
            mach_lib.update_mach_lua_log(assert(post_battle_all_factions_military_forces_list[enemy_faction_id], string.format('ERROR: Faction id "%s" is not in table "post_battle_all_factions_military_forces_list".', enemy_faction_id)))
            local post_battle_enemy_military_forces = post_battle_all_factions_military_forces_list[enemy_faction_id]

            for _, pre_battle_enemy_military_force in pairs(pre_battle_enemy_military_forces) do
                local post_battle_enemy_military_force = post_battle_enemy_military_forces[pre_battle_enemy_military_force.address]
                if not post_battle_enemy_military_force then
                    mach_lib.update_mach_lua_log('Post battle enemy military force not exists!!!!')
                end
                mach_lib.update_mach_lua_log(' ')
                mach_lib.update_mach_lua_log(string.format('Current faction turn: %s', mach_lib.__current_faction_turn_id__))
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.commander_name)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.commander_name)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.commander_type)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.commander_type)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.is_naval)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.is_naval)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.pos_x)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.pos_x)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.pos_y)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.pos_y)

                if post_battle_enemy_military_force then
                    mach_lib.update_mach_lua_log('Enemy soldier counts, pre battle')
                    mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.num_of_soldiers)
                    mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.num_of_units)
                    mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.num_of_ships)
                    mach_lib.update_mach_lua_log('Enemy soldier counts, post battle')
                    mach_lib.update_mach_lua_log(post_battle_enemy_military_force.num_of_soldiers)
                    mach_lib.update_mach_lua_log(post_battle_enemy_military_force.num_of_units)
                    mach_lib.update_mach_lua_log(post_battle_enemy_military_force.num_of_ships)
                end

                mach_lib.update_mach_lua_log(' ')

                if (pre_battle_winner_military_force.is_naval == pre_battle_enemy_military_force.is_naval) and
                        (
                            (pre_battle_winner_military_force.is_rebel and not post_battle_enemy_military_force) or
                            (
                            pre_battle_winner_military_force.is_naval and
                                    (mach_lib.find_distance(pre_battle_winner_military_force.pos_x, pre_battle_winner_military_force.pos_y, pre_battle_enemy_military_force.pos_x, pre_battle_enemy_military_force.pos_y) < 90)) or
                            (
                                not pre_battle_winner_military_force.is_naval and
                                        (mach_lib.find_distance(pre_battle_winner_military_force.pos_x, pre_battle_winner_military_force.pos_y, pre_battle_enemy_military_force.pos_x, pre_battle_enemy_military_force.pos_y) < 30))) and
                        (
                        (not post_battle_enemy_military_force) or
                                (
                                post_battle_enemy_military_force and
                                    (
                                    (post_battle_enemy_military_force.num_of_soldiers < pre_battle_enemy_military_force.num_of_soldiers) or
                                    (post_battle_enemy_military_force.num_of_ships < pre_battle_enemy_military_force.num_of_ships)))) then

                    pre_battle_loser_military_forces[#pre_battle_loser_military_forces+1] = pre_battle_enemy_military_force

                    mach_lib.update_mach_lua_log("pre battle loser military commander "..pre_battle_enemy_military_force.commander_name)
                    mach_lib.update_mach_lua_log("pre battle loser num_of_soldiers "..tostring(pre_battle_enemy_military_force.num_of_soldiers))
                    mach_lib.update_mach_lua_log("pre battle loser num_of_units "..tostring(pre_battle_enemy_military_force.num_of_units))

                    if post_battle_enemy_military_force then
                        post_battle_loser_military_forces[#post_battle_loser_military_forces+1] = post_battle_enemy_military_force
                        mach_lib.update_mach_lua_log("post battle loser military commander "..post_battle_enemy_military_force.commander_name)
                        mach_lib.update_mach_lua_log("post battle loser num_of_soldiers "..tostring(post_battle_enemy_military_force.num_of_soldiers))
                        mach_lib.update_mach_lua_log("post battle loser num_of_units "..tostring(post_battle_enemy_military_force.num_of_units))
                    end
                end
            end
        end
        if #pre_battle_loser_military_forces == 0 and #post_battle_loser_military_forces == 0 then
            mach_lib.update_mach_lua_log("Error, couldn't find loser military forces!")
        end

        mach_lib.update_mach_lua_log(string.format('Finished getting battle loser military forces for winner "%s", enemy number of forces found "%s".', pre_battle_winner_military_force.faction_id, #pre_battle_loser_military_forces))
        return pre_battle_loser_military_forces, post_battle_loser_military_forces
    end


    function _get_side_details_str(is_winner, battle, faction_names_str, commander_names_str)
        mach_lib.update_mach_lua_log("Getting side details string.")
        mach_lib.update_mach_lua_log(string.format('is_winner: "%s", faction_names_str: "%s", commander_names_str: "%s"', tostring(is_winner), faction_names_str, commander_names_str))

        local side_details_str = ''
        local side_description_str = ''
        local unit_type_str = ''
        local forces_casualties_number_str = 0
        local forces_total_number_str = 0
        local soldiers_on_ships_casualties_number = 0
        local soldiers_on_ships_total_number = 0

        if not battle.is_naval_battle then
            unit_type_str = 'soldiers'
            if is_winner then
                side_description_str = 'victors'
--                mach_lib.update_mach_lua_log('testing')
                if battle.pre_battle_winner_soldiers == 0 then
--                    mach_lib.update_mach_lua_log('testing 2')

                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
--                    mach_lib.update_mach_lua_log('testing a3')

                    forces_casualties_number_str = battle.winner_soldier_casualties
                    forces_total_number_str = battle.pre_battle_winner_soldiers
--                    mach_lib.update_mach_lua_log('testing 3')

                end
--                side_details_str = string.format('\n\nThe victors (%s), under the command of %s, lost %s soldier(s) out of %s soldier(s).', winner_faction_names_str, winner_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            else
                side_description_str = 'losers'
                if battle.pre_battle_loser_soldiers == 0 then
                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
                    forces_casualties_number_str = battle.loser_soldier_casualties
                    forces_total_number_str = battle.pre_battle_loser_soldiers
                end
--                side_details_str = string.format('\n\nThe vanquished (%s), under the command of %s, lost %s soldier(s) out of %s soldier(s).', loser_faction_names_str, loser_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            end
        else
            unit_type_str = 'ships'
            if is_winner then
                side_description_str = 'victors'
                if battle.pre_battle_winner_ships == 0 then
                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
                    forces_casualties_number_str = battle.winner_ship_casualties
                    forces_total_number_str = battle.pre_battle_winner_ships
                    if battle.pre_battle_winner_soldiers then
                        soldiers_on_ships_casualties_number = battle.winner_soldier_casualties
                        soldiers_on_ships_total_number =  battle.pre_battle_winner_soldiers
                    end
                end
--                side_details_str = string.format('\n\nThe victors (%s), under the command of %s, lost %s ship(s) out of %s ship(s).', winner_faction_names_str, winner_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            else
                side_description_str = 'losers'
                if battle.pre_battle_loser_ships == 0 then
                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
                    forces_casualties_number_str = battle.loser_ship_casualties
                    forces_total_number_str =  battle.pre_battle_loser_ships
                    if battle.pre_battle_loser_soldiers then
                        soldiers_on_ships_casualties_number = battle.loser_soldier_casualties
                        soldiers_on_ships_total_number =  battle.pre_battle_loser_soldiers
                    end
                end
--                side_details_str = string.format('\n\nThe vanquished (%s), under the command of %s, lost %s ship(s) out of %s ship(s).', loser_faction_names_str, loser_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            end
        end
--        mach_lib.update_mach_lua_log('testing 4')
--        mach_lib.update_mach_lua_log(side_description_str)
--        mach_lib.update_mach_lua_log(faction_names_str)
--        mach_lib.update_mach_lua_log(commander_names_str)
--        mach_lib.update_mach_lua_log(forces_casualties_number_str)
--        mach_lib.update_mach_lua_log(unit_type_str)
--        mach_lib.update_mach_lua_log(forces_total_number_str)

        side_details_str = string.format('\n\nThe %s (%s), under the command of %s, lost %s %s(s) out of %s %s(s).', side_description_str, faction_names_str, commander_names_str, forces_casualties_number_str, unit_type_str, forces_total_number_str, unit_type_str)

        if soldiers_on_ships_total_number > 0 then
            side_details_str = side_details_str..string.format('\nThe %s (%s), under the command of %s, lost %s soldier(s) out of %s soldier(s) embarked on ship(s).', side_description_str, faction_names_str, commander_names_str, soldiers_on_ships_casualties_number, soldiers_on_ships_total_number)
        end

        mach_lib.update_mach_lua_log(string.format('Finished getting side details string: "%s"', side_details_str))
        return side_details_str
    end


    function _get_unit_details_str(is_winner, get_captured, battle)
        mach_lib.update_mach_lua_log('Getting unit details str for message box.')
        local casualties_list = {}
        local side_faction_ids = {}
        local side_commander_casualties_list = {}

        if is_winner then
            side_faction_ids = battle.winner_faction_ids
            side_commander_casualties_list = battle.winner_commander_casualties_list
            if not battle.is_naval_battle then
                if not get_captured then
                    casualties_list = battle.winner_unit_casualties_list
                else
                    mach_lib.update_mach_lua_log('Getting winner prize unit details str for message box.')
                    casualties_list = battle.winner_unit_prizes_list
                end
            else
                if not get_captured then
                    casualties_list = mach_lib.concat_tables(battle.winner_ship_casualties_list, battle.winner_unit_casualties_list)
                else
                    mach_lib.update_mach_lua_log('Getting winner prize ship details str for message box.')
                    casualties_list = battle.winner_ship_prizes_list
                end
            end
        else
            side_faction_ids = battle.loser_faction_ids
            side_commander_casualties_list = battle.loser_commander_casualties_list
            if not battle.is_naval_battle then
                if not get_captured then
                    casualties_list = battle.loser_unit_casualties_list
                else
                    mach_lib.update_mach_lua_log('Getting loser captured unit details str for message box.')
                    casualties_list = battle.loser_unit_captured_list
                end
            else
                if not get_captured then
                    casualties_list = mach_lib.copy_table(battle.loser_ship_casualties_list)
                    for side_faction_idx=1, #side_faction_ids do
                        local side_faction_id = side_faction_ids[side_faction_idx]
                        if battle.loser_unit_casualties_list[side_faction_id] then
                            for unit_address, unit in  pairs(battle.loser_unit_casualties_list[side_faction_id]) do
                                casualties_list[side_faction_idx][unit_address] = unit
                            end
                        end
                    end
                else
                    mach_lib.update_mach_lua_log('Getting loser captured ship details str for message box.')
                    casualties_list = battle.loser_ship_captured_list
                end
            end
        end

        local unit_details_str = ''
        for side_faction_idx=1, #side_faction_ids do
            local side_faction_id = side_faction_ids[side_faction_idx]
            if casualties_list[side_faction_id] then
                unit_details_str = unit_details_str..string.format('\n- %s:', mach_lib.get_faction_screen_name_from_faction_id(side_faction_id))
                mach_lib.update_mach_lua_log('test')
                mach_lib.update_mach_lua_log(side_faction_id)

                for side_faction_id, side_commander_casualties in pairs(side_commander_casualties_list) do
                    mach_lib.update_mach_lua_log(side_faction_id)
                    mach_lib.update_mach_lua_log(side_commander_casualties)
                    for commander_casualty_idx, commander_casualty in pairs(side_commander_casualties) do
                        mach_lib.update_mach_lua_log('testa')
                        mach_lib.update_mach_lua_log(commander_casualty_idx)
                        mach_lib.update_mach_lua_log(commander_casualty)
                        unit_details_str = unit_details_str..string.format('\n- * Commander "%s" (killed)', commander_casualty)
                    end
                end
                mach_lib.update_mach_lua_log('test1')
                for address, unit in  pairs(casualties_list[side_faction_id]) do
                    if unit.regiment_name then
                        if unit.is_naval then
                            mach_lib.update_mach_lua_log('test1b')
                            if not unit.regiment_name == '' then
                                unit_details_str = unit_details_str..string.format('\n- * "%s" (%s of %s Guns, %s Men)', unit.regiment_name, unit.unit_name, unit.guns, unit.men)
                            else
                                unit_details_str = unit_details_str..string.format('\n- * (%s of %s Guns, %s Men)', unit.unit_name, unit.guns, unit.men)
                            end
                        else
                            mach_lib.update_mach_lua_log('test2')

                            if not unit.regiment_name == '' then
                                unit_details_str = unit_details_str..string.format('\n- * "%s" (%s)', unit.regiment_name, unit.unit_name)
                            else
                                unit_details_str = unit_details_str..string.format('\n- * (%s)', unit.unit_name)
                            end
                        end
                        mach_lib.update_mach_lua_log('test3')

                        if unit.commander_name ~= '' then
                            unit_details_str = unit_details_str..string.format(' commanded by "%s"', unit.commander_name)
                        end
                    end
                end
                mach_lib.update_mach_lua_log('test4')
                unit_details_str = unit_details_str..'\n'
            end
        end
        mach_lib.update_mach_lua_log(string.format('Finished getting unit details str for message box: "%s"', unit_details_str))
        return unit_details_str
    end


    function _populate_character_info_popup_with_battle_history()
        mach_lib.update_mach_lua_log(string.format('Populating character info popup with battle history.'))
--        local military_force = {}
--        local entity_type_selected = CampaignUI.EntityTypeSelected()
--        if entity_type_selected.Unit or entity_type_selected.Character then
--            local character_details = mach_lib.get_character_details_from_entity_type_selected(entity_type_selected)
--            if not character_details.IsNaval then
--                military_force = mach_classes.Army:new(character_details)
--            else
--                military_force = mach_classes.Navy:new(character_details)
--            end
--        elseif entity_type_selected.Settlement then
--            military_force = mach_lib.get_army_in_settlement_address(entity_type_selected.Entity)
--        end

        local selected_unit_card_unit_address = _get_moused_over_unit_card_unit_address()
        local character_faction_id = mach_lib.get_faction_id_from_unit_address(selected_unit_card_unit_address)
        local q_character_name = UIComponent(mach_lib.__wali_m_root__:Find("name_textbox"))
        mach_lib.update_mach_lua_log('test')

        local pop_up_charater_name = q_character_name:GetStateText()
        mach_lib.update_mach_lua_log(pop_up_charater_name)

        local utils = require("Utilities")
        mach_lib.update_mach_lua_log('test2')

        local character_battles, character_faction_id = mach_lib.get_battles_with_character_name(pop_up_charater_name, character_faction_id)
        local battle_history_str = 'Character Battle History\n\n'
        for character_battle_idx, character_battle in pairs(character_battles) do
            local combatant_faction_str = string.format('(%s vs %s)', mach_lib.get_battle_faction_names_str(character_battle.winner_faction_ids), mach_lib.get_battle_faction_names_str(character_battle.loser_faction_ids))
            if mach_lib.is_value_in_table(character_faction_id, character_battle.winner_faction_ids) then
                battle_history_str = battle_history_str..'* '..character_battle.battle_name..' (Victor) '..combatant_faction_str..'\n\n'
            else
                battle_history_str = battle_history_str..'* '..character_battle.battle_name..' (Loser) '..combatant_faction_str..'\n\n'
            end
        end
        local char_portrait = UIComponent(mach_lib.__wali_m_root__:Find("char_portrait"))
        if battle_history_str ~= 'Character Battle History\n\n' then
            char_portrait:SetTooltipText(tostring(battle_history_str))
        else
            battle_history_str = battle_history_str..'\nNo battle history.\n\n'
            char_portrait:SetTooltipText(tostring(battle_history_str))
        end
        mach_lib.update_mach_lua_log(string.format('Finished populating character info popup with battle history.'))
        return true
    end


    function _populate_entity_lists_regions_with_battle_history()
        mach_lib.update_mach_lua_log(string.format('Populating entity_lists "regions" tab with battle history. Battle number: %s', #mach_data.__battles_list__))
        local region_dy_ui = UIComponent(mach_lib.__wali_m_root__:Find("region_dy"))
--        mach_lib.update_mach_lua_log(region_dy_ui)

        --                local region_dy_ui = UIComponent(mach_lib.__wali_m_root__:Find("region_dy"))
--        mach_lib.update_mach_lua_log(region_dy_ui:GetStateText())
        local population_ui = UIComponent(mach_lib.__wali_m_root__:Find("population"))
--        mach_lib.update_mach_lua_log('garbage1')
--        mach_lib.update_mach_lua_log(population_ui:GetStateText())
--        mach_lib.update_mach_lua_log("garbage2b")
        local tabgroup_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("tabgroup"))
--        mach_lib.update_mach_lua_log("garbage2c")
--        mach_lib.update_mach_lua_log(tabgroup_ui_component:ChildCount())

        --            local tab_ui = UIComponent(tabgroup_ui:Find("3"))
        --            mach_lib.update_mach_lua_log(tab_ui)
        --            mach_lib.update_mach_lua_log(tab_ui:GetStateText())
--        mach_lib.update_mach_lua_log("garbage2d")
        local tab_ui_component = UIComponent(tabgroup_ui_component:Find("regions"))
--        mach_lib.update_mach_lua_log(tab_ui_component)
--        mach_lib.update_mach_lua_log("garbage2e")
--        mach_lib.update_mach_lua_log(tab_ui_component:ChildCount())
--        mach_lib.update_mach_lua_log(tab_ui_component:GetStateText())
--        mach_lib.update_mach_lua_log(UIComponent(tab_ui_component:Find(0)):GetStateText())
--        mach_lib.update_mach_lua_log(UIComponent(tab_ui_component:Find(1)):GetStateText())
        __regions_tab_tooltip__ = tab_ui_component:GetTooltipText()
        UIComponent(tab_ui_component:Find(1)):SetStateText("Battles")
        tab_ui_component:SetTooltipText("Shows battles of all factions. \n\nLeft click on battle to got battle location. Right click on battle to show its event message.", true)
--        mach_lib.update_mach_lua_log("garbage2ea")

--        mach_lib.update_mach_lua_log(UIComponent(tab_ui_component:Find(0)):ChildCount())
--        mach_lib.update_mach_lua_log(UIComponent(tab_ui_component:Find(1)):ChildCount())
--        mach_lib.update_mach_lua_log("garbage2eb")

--        mach_lib.update_mach_lua_log(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(0)):ChildCount())
--        mach_lib.update_mach_lua_log(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(1)):ChildCount())
--        mach_lib.update_mach_lua_log(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):ChildCount())
--        mach_lib.update_mach_lua_log(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(3)):ChildCount())
--        mach_lib.update_mach_lua_log(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(4)):ChildCount())
--        mach_lib.update_mach_lua_log(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(5)):ChildCount())
--        mach_lib.update_mach_lua_log("garbage2ec")

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(0)):Find(0)):SetStateText("Battle Name & Location")
        __regions_column_header_tooltip__ = UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(0)):GetTooltipText()
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(0)):SetTooltipText('Shows battle name (year) and location. \n\nSorts by location.', true)

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(1)):Find(0)):SetStateText("Participants")
        __population_column_header_tooltip__ = UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(1)):GetTooltipText()
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(1)):SetTooltipText('Shows factions participating in battle (winners vs losers).', true)

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(2)):Find(0)):SetStateText("Battle Type")
        __public_order_column_header_tooltip__ = UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(2)):GetTooltipText()
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(2)):SetTooltipText('Shows battle type. Crossed swords indicate major battle, anchor indicates naval battle and breastworks indicate a siege. \n\nSorts by major battle.', true)

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(3)):Find(0)):SetStateText("Casualties & Year, Turn")
        __income_column_header_tooltip__ = UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(3)):GetTooltipText()
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(3)):SetTooltipText('Shows total battle casualties (soldiers and/or ships), and year and turn of battle. \n\nSorts by turn.', true)

--        mach_lib.update_mach_lua_log("garbage2f")
        local list_box_ui = tab_ui_component:Find("list_box")
        local list_box_ui_component = UIComponent(list_box_ui)
--        mach_lib.update_mach_lua_log(list_box_ui)
--        mach_lib.update_mach_lua_log("garbage2g")
--        mach_lib.update_mach_lua_log(list_box_ui_component)
--        mach_lib.update_mach_lua_log(list_box_ui_component:GetStateText())
--        mach_lib.update_mach_lua_log("garbage2h")
--        mach_lib.update_mach_lua_log(list_box_ui_component:ChildCount())

        --            local tab = UIComponent(entity_lists:Find("3"))
        --            local entity_lists_ui = mach_lib.__wali_m_root__:Find('entity_lists')
        --            mach_lib.update_mach_lua_log("garbage2e")
        --            mach_lib.update_mach_lua_log(entity_lists_ui:GetStateText())
--        mach_lib.update_mach_lua_log("garbage3")
        --            local list_box_ui = mach_lib.__wali_m_root__:Find("list_box")
        --            mach_lib.update_mach_lua_log(list_box_ui)
--        mach_lib.update_mach_lua_log("garbage3a")
        --            local list_box_ui_component = UIComponent(list_box_ui)
        --            mach_lib.update_mach_lua_log(list_box_ui_component)
        --            mach_lib.update_mach_lua_log(list_box_ui_component:GetStateText())
--        mach_lib.update_mach_lua_log("garbage3b")
        --            mach_lib.update_mach_lua_log(list_box_ui_component:ChildCount())
        list_box_ui_component:DestroyChildren()
        mach_lib.update_mach_lua_log(list_box_ui_component:ChildCount())
--        mach_lib.update_mach_lua_log("garbage3c")
        --            mach_lib.update_mach_lua_log(list_box_ui_component:ChildCount())
--        mach_lib.update_mach_lua_log("garbage4")
        local regions_tab_ui = mach_lib.__wali_m_root__:Find("regions")
--        mach_lib.update_mach_lua_log(regions_tab_ui)
        local regions_tab_ui_component = UIComponent(regions_tab_ui)
--        mach_lib.update_mach_lua_log(regions_tab_ui_component:GetStateText())
--        mach_lib.update_mach_lua_log(regions_tab_ui_component)
--        regions_tab_ui_component:SetStateText('Battles')
--        mach_lib.update_mach_lua_log("garbage4a")
--        mach_lib.update_mach_lua_log(regions_tab_ui_component:ChildCount())
--        mach_lib.update_mach_lua_log("garbage4b")
        regions_tab_ui_component:Visible(true)
--        mach_lib.update_mach_lua_log("garbage4c")

        local tab_title_ui = mach_lib.__wali_m_root__:Find("tab_title")
        mach_lib.update_mach_lua_log(tab_title_ui)
        local tab_title_ui_component = UIComponent(tab_title_ui)
        mach_lib.update_mach_lua_log(tab_title_ui_component)
        mach_lib.update_mach_lua_log(tab_title_ui_component:GetStateText())
--        tab_title_ui_component:SetVisible(false)


--        mach_lib.update_mach_lua_log("garbage4d")
        local public_order_title_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("public_order_title"))
        public_order_title_ui_component:SetStateText('Year')

--        local tabgroup_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("tabgroup"))
--        mach_lib.update_mach_lua_lot(tabgroup_ui_component)
--        mach_lib.update_mach_lua_lot(tabgroup_ui_component:ChildCount())
--        local regions_tab_ui_2 = tabgroup_ui_component:Find(2)
--        mach_lib.update_mach_lua_lot(regions_tab_ui_2)
--        mach_lib.update_mach_lua_lot(regions_tab_ui_2:GetStateText())

        --        local player_faction_region_count = #CampaignUI.RetrieveFactionRegionList(CampaignUI.PlayerFactionId())
        local battle_count = 0
--        mach_lib.update_mach_lua_log("garbage5")

--        local utils = require("Utilities")
--        local panel_manager = utils.Require("PanelManager")
--        mach_lib.update_mach_lua_log("garbage5a")
--        local lists_panel = panel_manager.IsPanelOpen("entity_lists")
--        mach_lib.update_mach_lua_log("garbage5b")
--        if lists_panel ~= nil then
--            UIComponent(lists_panel):LuaCall("Reinitialise")
--        end

        for battle_idx, battle in pairs(mach_data.__battles_list__) do
            battle_count = battle_count + 1
            mach_lib.update_mach_lua_log(battle_count)
            mach_lib.update_mach_lua_log("item"..tostring(battle_count))

--            mach_lib.update_mach_lua_log("garbage5c")

--            mach_lib.update_mach_lua_log("garbage5e")
            local battle_item = UIComponent(Component.CreateComponentFromTemplate("row_template_region", "item" .. tostring(battle_count), list_box_ui, 0, 0))
--            mach_lib.update_mach_lua_log("garbage5a")
            battle_item:LuaCall("Initialise", battle, true)
--            mach_lib.update_mach_lua_log("garbage5b")
            mach_lib.update_mach_lua_log(list_box_ui_component:ChildCount())
--            mach_lib.update_mach_lua_log("garbage6")

            battle_item:SetEventCallback("OnMouseLClickUp", function()
                CampaignUI.SetCameraTarget(battle.pos_x, battle.pos_y)
            end)

--            local m_last_sort = {}
--            m_last_sort["regions"] = {0, false }
--            mach_lib.update_mach_lua_log("garbage6a")
--            local m_tabs = {}
--            m_tabs["regions"] = {}
--            m_tabs["regions"].tab =  UIComponent(tabgroup_ui_component:Find("regions"))
--            local tab_find_ui = m_tabs["regions"].tab:Find(0)
--            mach_lib.update_mach_lua_log(tab_find_ui)
--            local sortable_list = UIComponent(tab_find_ui)
--            mach_lib.update_mach_lua_log("garbage6aa")
--            local entity_lists = loadfile("ui/campaign ui/entity_lists_scripts/entity_lists")
--            mach_lib.update_mach_lua_log("garbage6ab")
--            entity_lists.RecolorList(sortable_list)
--            mach_lib.update_mach_lua_log("garbage6ac")
--            sortable_list:SetGlobal("g_notify_func", entity_lists.Sorted)
--            mach_lib.update_mach_lua_log("garbage6ad")

--            m_last_sort["regions"] = {
--                Component.CallByAddress(m_tabs["regions"].tab:Find(0), "LuaCall", "LastSorted")
--            }
--            mach_lib.update_mach_lua_log("garbage6b")
--            mach_lib.update_mach_lua_log(m_tabs.regions.tab)
--            mach_lib.update_mach_lua_log(m_tabs.regions.tab:Find(0))
--            mach_lib.update_mach_lua_log("garbage6c")
--            mach_lib.update_mach_lua_log(m_last_sort.regions[1])
--            mach_lib.update_mach_lua_log(m_last_sort.regions[2])
--
--            local region_column_ui_component = UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(0)):Find(0))
--            mach_lib.update_mach_lua_log("garbage6d")
--
--            Component.CallByAddress(m_tabs.regions.tab:Find(0), "LuaCall", "InitialSort", m_last_sort.regions[1], m_last_sort.regions[2])

--            mach_lib.update_mach_lua_log("garbage7")

        end
--        mach_lib.update_mach_lua_log("garbage8")
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(0)):ForceEvent("OnMouseLClickUp")

        mach_lib.update_mach_lua_log(string.format('Finished populating entity_lists "regions" tab with battle history.'))
    end


    function _populate_unit_info_popup_with_battle_history()
        mach_lib.update_mach_lua_log(string.format('Populating unit info popup with battle history.'))

        local selected_unit_card_unit_address = _get_moused_over_unit_card_unit_address()

        if selected_unit_card_unit_address then
            local unit_details = CampaignUI.InitialiseUnitDetails(selected_unit_card_unit_address)
            mach_lib.update_mach_lua_log(unit_details)
            mach_lib.update_mach_lua_log('bugger1')
            mach_lib.update_mach_lua_log(unit_details.Id)

            mach_lib.update_mach_lua_log('bugger2')
            local g_textview_text = UIComponent(mach_lib.__wali_m_root__:Find("Text"))
            mach_lib.update_mach_lua_log('bugger5')

            local battle_history_str = 'Unit Battle History\n'

            if g_textview_text:GetStateText():find('Unit Battle History') == nil and mach_data.__unit_id_to_unit_unique_ids__[unit_details.Id] then
                mach_lib.update_mach_lua_log(unit_details.Id)
                local unit_unique_id = mach_data.__unit_id_to_unit_unique_ids__[unit_details.Id][#mach_data.__unit_id_to_unit_unique_ids__[unit_details.Id]]
                mach_lib.update_mach_lua_log('test5')
                mach_lib.update_mach_lua_log(unit_unique_id)

                local unit_battles = mach_lib.get_battles_with_unit_unique_id(unit_unique_id)
                mach_lib.update_mach_lua_log('test6')

                for unit_battle_idx, unit_battle in pairs(unit_battles) do
                    local combatant_faction_str = string.format('(%s vs %s)', mach_lib.get_battle_faction_names_str(unit_battle.winner_faction_ids), mach_lib.get_battle_faction_names_str(unit_battle.loser_faction_ids))
                    local casualties_str
                    local pre_battle_entity_list
                    local post_battle_entity_list
                    local unit_faction_id
                    if not unit_details.IsNaval then
                        mach_lib.update_mach_lua_log('logger')
--                        mach_lib.output_table_to_mach_log(unit_battle.pre_battle_units_list, 1)
                        for pre_battle_faction_id, pre_battle_faction_units_list in pairs(unit_battle.pre_battle_units_list) do
                            mach_lib.update_mach_lua_log('logger1a')
--                            mach_lib.output_table_to_mach_log(pre_battle_faction_units_list, 1)
                            mach_lib.update_mach_lua_log(pre_battle_faction_id)

                            for pre_battle_unit_idx, pre_battle_unit in pairs(pre_battle_faction_units_list) do
                                mach_lib.update_mach_lua_log('logger1a -b ')
--                                mach_lib.output_table_to_mach_log(pre_battle_unit, 1)

                                if pre_battle_unit.unit_id == unit_details.Id then
                                    unit_faction_id = pre_battle_faction_id
                                    for post_battle_faction_id, post_battle_faction_units_list in pairs(unit_battle.post_battle_units_list) do
                                        mach_lib.update_mach_lua_log('logger1b')

                                        for post_battle_unit_idx, post_battle_unit in pairs(post_battle_faction_units_list) do
                                            mach_lib.update_mach_lua_log('logger2')
                                            if post_battle_unit.unit_id == unit_details.Id then
                                                casualties_str = string.format('(%s soldier(s) killed)', pre_battle_unit.men - post_battle_unit.men)
                                            end
                                        end
                                    end
                                    if not casualties_str then
                                        casualties_str = string.format('(%s soldier(s) killed)', pre_battle_unit.men)
                                    end
                                end
                            end
                        end
                    else
                        for pre_battle_faction_id, pre_battle_faction_ships_list in pairs(unit_battle.pre_battle_ships_list) do
                            for pre_battle_ship_idx, pre_battle_ship in pairs(unit_battle.pre_battle_faction_ships_list) do
                                mach_lib.update_mach_lua_log('logger1asdf')
                                if pre_battle_ship.unit_id == unit_details.Id then
                                    unit_faction_id = pre_battle_faction_id
                                    for post_battle_faction_id, post_battle_faction_ships_list in pairs(unit_battle.post_battle_ships_list) do
                                        for post_battle_ship_idx, post_battle_ship in pairs(post_battle_faction_ships_list) do
                                            mach_lib.update_mach_lua_log('logger3')
                                            if post_battle_ship.unit_id == unit_details.Id then
                                                casualties_str = string.format('(%s men killed, %s gun(s) damaged)', pre_battle_ship.men - post_battle_ship.men, pre_battle_ship.guns - post_battle_ship.guns)
                                            end
                                        end

                                    end
                                    if not casualties_str then
                                        casualties_str = string.format('(%s men killed, %s gun(s) damaged)', pre_battle_ship.men, pre_battle_ship.guns)
                                    end
                                end
                            end
                        end
                    end
                    mach_lib.update_mach_lua_log('logger4')

                    if mach_lib.is_value_in_table(unit_faction_id, unit_battle.winner_faction_ids) then
                        battle_history_str = battle_history_str..'* '..unit_battle.battle_name..' (Victor) '..combatant_faction_str..' '..casualties_str..'\n'
                    else
                        battle_history_str = battle_history_str..'* '..unit_battle.battle_name..' (Loser) '..combatant_faction_str..' '..casualties_str..'\n'
                    end
                end
            end
            if battle_history_str ~= 'Unit Battle History\n' then
                g_textview_text:SetStateText(tostring(battle_history_str..'\n\n'..g_textview_text:GetStateText()))
            else
                battle_history_str = battle_history_str..'\nNo battle history.\n\n'
                g_textview_text:SetStateText(tostring(battle_history_str..'\n\n'..g_textview_text:GetStateText()))
            end
        else
            mach_lib.update_mach_lua_log(string.format('Error, could not get unit card address to populate unit info popup with battle history!'))
            return false
        end
        mach_lib.update_mach_lua_log(string.format('Finished populating unit info popup with battle history.'))
        return true
    end

    function _process_created_character_military_force(character_context)
        mach_lib.update_mach_lua_log(string.format('Processing created character military force.'))
        local pre_battle_military_force
        local post_battle_military_force
        local character_details = mach_lib.get_character_details_from_character_context(character_context, "CharacterCreated")
--        local contained_entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(character_details.Address, character_details.Address)
        local contained_units
        local faction_id = mach_lib.get_faction_id_from_context(character_context, "CharacterCreated")
        if not character_details.is_naval then
            post_battle_military_force = mach_classes.Army:new(character_details, faction_id)
            contained_units  = post_battle_military_force.units
        else
            post_battle_military_force = mach_classes.Navy:new(character_details, faction_id)
            contained_units = post_battle_military_force.ships
        end
        local pre_battle_faction_military_forces = mach_data.__all_factions_military_forces_list__[faction_id]
        for _, contained_unit in pairs(contained_units) do
            pre_battle_military_force = mach_lib.get_military_force_from_unit_id(pre_battle_faction_military_forces, contained_unit.unit_id)
            if pre_battle_military_force then
                break
            end
        end
        if pre_battle_military_force then
            if not __winner_unit_seen__ then
                __current_battle__:add_winner_military_force(pre_battle_military_force, true, nil)
                __current_battle__:add_winner_military_force(post_battle_military_force, false, nil)
                mach_lib.update_mach_lua_log("Setting __winner_unit_seen__ to \"true\"")
                __winner_unit_seen__ = true
            else
                __current_battle__:add_loser_military_force(pre_battle_military_force, true, nil)
                __current_battle__:add_loserr_military_force(post_battle_military_force, false, nil)
                mach_lib.update_mach_lua_log("Setting __loser_unit_seen__ to \"true\"")
                __loser_unit_seen__ = true
            end
            mach_lib.update_mach_lua_log(string.format('Finished processing created character military force.'))
        else
            mach_lib.update_mach_lua_log(string.format('Error, unable to process created character military force.'))
        end
    end


    function _reset_entity_lists_regions_tab()
        mach_lib.update_mach_lua_log('Resetting "entity_lists" regions tab.')
        local tabgroup_ui = UIComponent(mach_lib.__wali_m_root__:Find("tabgroup"))
        local tab_ui_component = UIComponent(tabgroup_ui:Find("regions"))
        UIComponent(tab_ui_component:Find(1)):SetStateText("Regions")

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(0)):Find(0)):SetStateText("Regions")

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(1)):Find(0)):SetStateText("Population")

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(2)):Find(0)):SetStateText("Public Order")

        UIComponent(UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(3)):Find(0)):SetStateText("Income")


--        if __regions_tab_tooltip__ then
--        tab_ui_component:SetTooltipText(__regions_tab_tooltip__, true)
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(0)):SetTooltipText(__regions_column_header_tooltip__, true)
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(1)):SetTooltipText(__population_column_header_tooltip__, true)
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(2)):SetTooltipText(__public_order_column_header_tooltip__, true)
        UIComponent(UIComponent(UIComponent(tab_ui_component:Find(0)):Find(2)):Find(3)):SetTooltipText(__income_column_header_tooltip__, true)
--        end
        local upper_class_reaction_icon_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("upper_class_reaction_icon", true))
        local major_battle_image = UIImage("data/ui/templates/skins/upper-classes_neutral.tga")
        mach_lib.update_mach_lua_log('shit13a')
--        mach_lib.update_mach_lua_log(upper_class_reaction_icon_ui_component:Address())
        major_battle_image:SetComponentTexture(upper_class_reaction_icon_ui_component:Address(), 0)

        mach_lib.update_mach_lua_log('shit13ab')

        local lower_class_reaction_icon_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("lower_class_reaction_icon", true))
        local major_battle_image = UIImage("data/ui/templates/skins/lower-classes_angry.tga")
        mach_lib.update_mach_lua_log('shit13b')
        major_battle_image:SetComponentTexture(lower_class_reaction_icon_ui_component:Address(), 0)

        local utils = require("Utilities")
        local panel_manager = utils.Require("PanelManager")
        local lists_panel = panel_manager.IsPanelOpen("entity_lists")
        if lists_panel ~= nil then
            UIComponent(lists_panel):LuaCall("Reinitialise")
        end
        mach_lib.update_mach_lua_log('Finished resetting "entity_lists" regions tab."')
    end


    function _show_battle_message_box(battle)
        mach_lib.update_mach_lua_log("Showing battle message box.")
        battle.message_auto_show = false
        battle.message_screen_height = 960
        battle.message_screen_width = 1280
        battle.message_icon = "data/ui/eventicons/news.tga"
        battle.message_event = ""
        battle.message_image = _get_battle_message_image(battle)
        battle.message_title, battle.message_text = _get_battle_message_title_and_text(battle)
        battle.message_data = {SubTitle = "", MoviePath = "", PosX = battle.pos_x, PosY = battle.pos_y, PosZ = 0}
        battle.message_layout = "standard"
        battle.message_requires_response = false
        if not battle.is_player_battle then
            mach_lib.show_message_box(battle.message_auto_show, battle.message_screen_height, battle.message_screen_width, battle.message_icon, battle.message_text, battle.message_event, battle.message_image, battle.message_title, battle.message_data, battle.message_layout, battle.message_requires_response)
        else
            mach_lib.update_mach_lua_log('Is Player Battle, will not show Battle Message Box.')
        end
        mach_lib.update_mach_lua_log("Finished showing battle message box.")
    end


    local function on_campaign_settlement_attacked(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - CampaignSettlementAttacked")
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished CampaignSettlementAttacked")
    end


    local function on_character_completed_battle(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - CharacterCompletedBattle")

        if __winner_unit_seen__ == false and __loser_unit_seen__ == false then
            mach_lib.update_mach_lua_log("New battle to process.")
--            if conditions.CharacterWonBattle(context) then
--                mach_lib.update_mach_lua_log("Character won battle.")
--            else
--                mach_lib.update_mach_lua_log("Character lost battle.")
--            end
            __current_battle__ = mach_classes.Battle:new()
            mach_lib.update_mach_lua_log('Adding time trigger of 0.01 seconds for "battle_processing_completed"')
            mach_lib.scripting.game_interface:add_time_trigger("battle_processing_completed", 0.01)
        end

        local character_details = mach_lib.get_character_details_from_character_context(context, "CharacterCompletedBattle")

        local faction_id = mach_lib.get_faction_id_from_context(context, "CharacterCompletedBattle")

        if string.find(faction_id, 'rebels') then
            __rebel_character_completed_battle__ = true
        else
            __rebel_character_completed_battle__ = false
        end

        local post_battle_military_force = nil
        if character_details == nil then
--            mach_lib.update_mach_lua_log('tank')
            post_battle_military_force = mach_classes.Army:new(nil, faction_id, context)
        else
--            mach_lib.update_mach_lua_log('tank2')
            if not character_details.IsNaval then
                post_battle_military_force = mach_classes.Army:new(character_details, faction_id)
            else
                post_battle_military_force = mach_classes.Navy:new(character_details, faction_id)
            end
        end

        local is_attacker = nil;
        if conditions.CharacterWasAttacker(context) then
            mach_lib.update_mach_lua_log("Character was attacker during battle.")
            is_attacker = true
        else
            mach_lib.update_mach_lua_log("Character was defender during battle.")
            is_attacker = false
        end

        if conditions.CharacterWonBattle(context) then
            mach_lib.update_mach_lua_log("Character won battle.")
            local pre_battle_winner_military_force = nil
            if character_details == nil then
                mach_lib.update_mach_lua_log("test1c")
                pre_battle_winner_military_force = post_battle_military_force
            else
                mach_lib.update_mach_lua_log("test1d")
                for faction_id2, faction_id2_value in pairs(mach_data.__all_factions_military_forces_list__) do
                    mach_lib.update_mach_lua_log("test1d3a")
                    mach_lib.update_mach_lua_log(faction_id2)
                end
                mach_lib.update_mach_lua_log("test1d3")
                assert(mach_data.__all_factions_military_forces_list__[faction_id], mach_lib.update_mach_lua_log(string.format('ERROR: Faction id "%s" not in "mach_data.__all_factions_military_forces_list__"!', faction_id)))
                pre_battle_winner_military_force = mach_data.__all_factions_military_forces_list__[faction_id][post_battle_military_force.address]
            end
            mach_lib.update_mach_lua_log("test1e")
            __current_battle__:add_winner_military_force(pre_battle_winner_military_force, true, is_attacker)
            __current_battle__:add_winner_military_force(post_battle_military_force, false, is_attacker)
            mach_lib.update_mach_lua_log("Setting __winner_unit_seen__ to \"true\"")
            __winner_unit_seen__ = true
        else
            mach_lib.update_mach_lua_log("Character lost battle.")
            local pre_battle_loser_military_force = nil
            if character_details == nil then
                mach_lib.update_mach_lua_log("test")
                pre_battle_loser_military_force = post_battle_military_force
            else
                mach_lib.update_mach_lua_log("test2")
                pre_battle_loser_military_force = mach_data.__all_factions_military_forces_list__[faction_id][post_battle_military_force.address]
            end
            mach_lib.update_mach_lua_log("test3")
            __current_battle__:add_loser_military_force(pre_battle_loser_military_force, true, is_attacker)
            __current_battle__:add_loser_military_force(post_battle_military_force, false, is_attacker)
            mach_lib.update_mach_lua_log("Setting __loser_unit_seen__ to \"true\"")
            __loser_unit_seen__ = true
        end

        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished CharacterCompletedBattle")
    end


    local function on_character_created(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - CharacterCreated")
        if __current_battle__ ~= nil and __loser_unit_seen__ then
            _process_created_character_military_force(context)
        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished CharacterCreated")
    end

    local function on_component_left_click_up(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - ComponentLClickUp")
        if __entity_lists_panel_opened__ then
            mach_lib.update_mach_lua_log('"entity_lists" panel is opened.')
            local tabgroup_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("tabgroup"))
            local tab_ui_component = UIComponent(tabgroup_ui_component:Find("regions"))
--            mach_lib.update_mach_lua_log(context.component)
--            mach_lib.update_mach_lua_log(tabgroup_ui_component:Find("regions"))
            if __regions_tab_tooltip__ and (conditions.IsComponentType("armies", context) or conditions.IsComponentType("fleets", context) or conditions.IsComponentType("agents", context))then
                mach_lib.update_mach_lua_log('Setting "regions" tab to "Regions"')
                UIComponent(tab_ui_component:Find(1)):SetStateText("Regions")
                tab_ui_component:SetTooltipText(__regions_tab_tooltip__, true)
            end

            if __regions_tab_opened__ and conditions.IsComponentType("regions", context) and context.component == tabgroup_ui_component:Find("regions") then
                __regions_tab_opened__ = false
                mach_lib.update_mach_lua_log('Clicked on "regions" tab AGAIN in "entity_lists" panel')
--                mach_lib.output_table_to_mach_log(context, 1)
                _populate_entity_lists_regions_with_battle_history()
            elseif conditions.IsComponentType("regions", context) and context.component == tabgroup_ui_component:Find("regions") then
                mach_lib.update_mach_lua_log('Clicked on "regions" tab in "entity_lists" panel')
                __regions_tab_opened__ = true
                if __regions_tab_tooltip__ then
                    _reset_entity_lists_regions_tab()
                end
            elseif conditions.IsComponentType("armies", context) or conditions.IsComponentType("fleets", context) or conditions.IsComponentType("agents", context) then
                mach_lib.update_mach_lua_log('Clicked on "armies", "fleets" or "agents" tab in "entity_lists" panel')
                __regions_tab_opened__ = false
            else

                --            __entity_lists_panel_opened__ = false
--                local region_dy_ui = UIComponent(mach_lib.__wali_m_root__:Find("region_dy"))
--                if region_dy_ui:GetStateText() then
--                    mach_lib.update_mach_lua_log('Adding time trigger of 0.01 seconds for "entity_lists_regions_populated"')
--                    mach_lib.scripting.game_interface:add_time_trigger("entity_lists_regions_populated", 0.01)
--
--                end
            end
        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished ComponentLClickUp")
    end


    local function on_faction_turn_start(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - FactionTurnStart")
        __winner_unit_seen__ = false
        __loser_unit_seen__ = false
        __rebel_character_completed_battle__ = false
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished FactionTurnStart")
    end


    local function on_garrison_residence_captured(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - GarrisonResidenceCaptured")

    end


    local function on_panel_closed_campaign(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - PanelClosedCampaign")
        --Show battle history in unit info popup
        if conditions.IsComponentType('entity_lists', context) then
            mach_lib.update_mach_lua_log('"entity_lists" panel closed.')
            __entity_lists_panel_opened__ = false
--            __regions_tab_opened__ = false
--            local tabgroup_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("tabgroup"))
--            local tab_ui_component = UIComponent(tabgroup_ui_component:Find("regions"))
--            UIComponent(tab_ui_component:Find(1)):SetStateText("Regions")
        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished PanelClosedCampaign")
    end


    local function on_panel_opened_campaign(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - PanelOpenedCampaign")
        --Show battle history in unit info popup
        if conditions.IsComponentType("UnitInfoPopup", context) or conditions.IsComponentType("CharacterInfoUnitInfoPopup", context) then
            mach_lib.update_mach_lua_log('Showing UnitInfoPopup or CharacterInfoUnitInfoPopup')
            if not _populate_unit_info_popup_with_battle_history() then
                mach_lib.update_mach_lua_log("Error, could not populate unit info pop-up!")
            end
        elseif conditions.IsComponentType('CharacterInfoPopup', context) then
            if not _populate_character_info_popup_with_battle_history() then
                mach_lib.update_mach_lua_log("Error, could not populate character info pop-up!")
            end
        elseif conditions.IsComponentType('entity_lists', context) then
            mach_lib.update_mach_lua_log('"entity_lists" panel opened')
            __entity_lists_panel_opened__ = true

            --            mach_lib.update_mach_lua_log(context.component)
            --            mach_lib.update_mach_lua_log(tabgroup_ui_component:Find("regions"))
            if __regions_tab_tooltip__ then
                mach_lib.update_mach_lua_log('Resetting "regions" tab to "Regions" and setting tooltip.')
                local tabgroup_ui_component = UIComponent(mach_lib.__wali_m_root__:Find("tabgroup"))
                local tab_ui_component = UIComponent(tabgroup_ui_component:Find("regions"))
                UIComponent(tab_ui_component:Find(1)):SetStateText("Regions")
                tab_ui_component:SetTooltipText(__regions_tab_tooltip__, true)
            end
        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished PanelOpenedCampaign")
    end


    local function on_time_trigger(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - TimeTrigger")
        if context.string == "battle_processing_completed" then
            mach_lib.update_mach_lua_log('Caught "battle_processing_completed" time trigger.')
            _finish_processing_battle()
        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished TimeTrigger")
    end


    local function on_ui_created(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - UICreated")
    end


    local function on_unit_completed_battle(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - UnitCompletedBattle")
        if __rebel_character_completed_battle__ then
            local unit_culture = mach_lib.get_unit_culture_from_unit_context(context)
            if conditions.UnitWonBattle(context) then
                __current_battle__.winner_faction_ids = mach_lib.update_numbered_list(__current_battle__.winner_faction_ids, 'rebels')
                __current_battle__.winner_culture = unit_culture
                if not __current_battle__.is_naval_battle then
                    __current_battle__.pre_battle_winner_units = __current_battle__.pre_battle_winner_units + 1
                else
                    __current_battle__.pre_battle_winner_ships = __current_battle__.pre_battle_winner_ships + 1
                end
            else
                __current_battle__.loser_faction_ids = mach_lib.update_numbered_list(__current_battle__.loser_faction_ids, 'rebels')
                __current_battle__.loser_culture = unit_culture
                if not __current_battle__.is_naval_battle then
                    __current_battle__.pre_battle_loser_units = __current_battle__.pre_battle_loser_units + 1
                else
                    __current_battle__.pre_battle_loser_ships = __current_battle__.pre_battle_loser_ships + 1
                end
            end
            if not __current_battle__.is_naval_battle then
                __current_battle__.pre_battle_units = __current_battle__.pre_battle_units + 1
            else
                __current_battle__.pre_battle_ships = __current_battle__.pre_battle_ships + 1
            end
        end

--        if not conditions.UnitWonBattle(context) then
--
--        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished UnitCompletedBattle")
    end


    events.PreBattle[#events.PreBattle+1] = function(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - PreBattle")
    end

    events.DummyEvent[#events.DummyEvent+1] = function(context)
        mach_lib.update_mach_lua_log("DummyEvent")
        if conditions.UnitWonBattle(context) then
            mach_lib.update_mach_lua_log("dummy event2")
        end
    end

    mach_lib.scripting.AddEventCallBack("CampaignSettlementAttacked", on_campaign_settlement_attacked)
    mach_lib.scripting.AddEventCallBack("CharacterCompletedBattle", on_character_completed_battle)
    mach_lib.scripting.AddEventCallBack("CharacterCreated", on_character_created)
    mach_lib.scripting.AddEventCallBack("ComponentLClickUp", on_component_left_click_up)
    mach_lib.scripting.AddEventCallBack("FactionTurnStart", on_faction_turn_start)
    mach_lib.scripting.AddEventCallBack("GarrisonResidenceCaptured", on_garrison_residence_captured)
    mach_lib.scripting.AddEventCallBack("PanelClosedCampaign", on_panel_closed_campaign)
    mach_lib.scripting.AddEventCallBack("PanelOpenedCampaign", on_panel_opened_campaign)
    mach_lib.scripting.AddEventCallBack("TimeTrigger", on_time_trigger)
    mach_lib.scripting.AddEventCallBack("UICreated", on_ui_created)
    mach_lib.scripting.AddEventCallBack("UnitCompletedBattle", on_unit_completed_battle)
end






