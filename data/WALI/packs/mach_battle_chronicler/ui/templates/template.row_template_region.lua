local utils = require("Utilities")
mach_lib = require "WALI/mach_lib"
local m_region
local this = UIComponent(Address)
local m_settlement_interface
sort_columns = {}
__battle_details__ = nil

function _populate_row_template_with_battle(battle_details)
    mach_lib.update_mach_lua_log(string.format('Processing battle "%s" for row_template_region', battle_details.battle_name))
    __battle_details__ = battle_details
    mach_lib.update_mach_lua_log(this)
    --    m_region = details.Address
    local winners_losers_str = string.format('%s vs %s', mach_lib.get_battle_faction_names_str(battle_details.winner_faction_ids), mach_lib.get_battle_faction_names_str(battle_details.loser_faction_ids))
    sort_columns = {
        battle_details.battle_name,
        winners_losers_str,
        tostring(battle_details.is_major_battle),
        battle_details.turn
    }
    local region_dy_ui_component = UIComponent(this:Find("region_dy"))
    --    mach_lib.update_mach_lua_log(mach_lib.output_table_to_mach_log(region_dy_ui_component:GetStateTextDetails(),2))
    region_dy_ui_component:SetStateText(battle_details.battle_name, true, 2)
    local capital_dy_ui_component = UIComponent(this:Find("capital_dy"))
    capital_dy_ui_component:SetStateText(battle_details.location)
    mach_lib.update_mach_lua_log(capital_dy_ui_component:GetStateTextDetails())
    capital_dy_ui_component:Resize(capital_dy_ui_component:Width() + 35, capital_dy_ui_component:Height() + 40)
    local capital_dy_ui_component_x, capital_dy_ui_component_y = capital_dy_ui_component:Position()
    capital_dy_ui_component:MoveTo(capital_dy_ui_component_x - 13, capital_dy_ui_component_y)
    --      capital_dy_ui_component:SetStateTextDetails( {
    --      ["XOffset"] = -5} )
    local population_ui_component = UIComponent(this:Find("population"))
    population_ui_component:SetStateText(winners_losers_str)
    population_ui_component:Resize(population_ui_component:Width() + 41, population_ui_component:Height() + 35)
    local population_ui_component_x, population_ui_component_y = population_ui_component:Position()
    population_ui_component:MoveTo(population_ui_component_x - 35, population_ui_component_y - 20)
    --      mach_lib.update_mach_lua_log(mach_lib.output_table_to_mach_log(population_ui_component:GetStateTextDetails(), 2))
    local percentage_ui_component = UIComponent(this:Find("percentage"))
    --    percentage_ui_component:SetStateText(winners_losers_str)
    percentage_ui_component:SetVisible(false)
    local tax_tx_ui_component = UIComponent(this:Find("tax_tx", true))
    tax_tx_ui_component:SetStateText(string.format('Year: %s, Turn: %s', battle_details.year, battle_details.turn))
    tax_tx_ui_component:Resize(tax_tx_ui_component:Width() + 50, tax_tx_ui_component:Height())
    local tax_tx_ui_component_x, tax_tx_ui_component_y = tax_tx_ui_component:Position()
    tax_tx_ui_component:MoveTo(tax_tx_ui_component_x - 70, tax_tx_ui_component_y)
    mach_lib.update_mach_lua_log(string.format('Year: %s, Turn: %s', battle_details.year, battle_details.turn))
    tax_tx_ui_component:SetVisible(true)

    local money_ui_component = UIComponent(this:Find("money"))
    local casualties_str = ''
    if not battle_details.is_naval_battle then
        casualties_str = string.format('%s Soldier(s)', battle_details.total_soldier_casualties)
        mach_lib.update_mach_lua_log(casualties_str)
    else
        casualties_str = string.format('%s Ship(s), %s Soldier(s)',battle_details.total_ship_casualties, battle_details.total_soldier_casualties)
        mach_lib.update_mach_lua_log(casualties_str)
    end

    money_ui_component:SetStateText(casualties_str)
    money_ui_component:Resize(money_ui_component:Width() + 45, money_ui_component:Height())
    local money_ui_component_x, money_ui_component_y = money_ui_component:Position()
    money_ui_component:MoveTo(money_ui_component_x - 45, money_ui_component_y)
    mach_lib.update_mach_lua_log(money_ui_component:GetStateTextDetails())
    --    local states = {
    --      "up",
    --      "up",
    --      "up",
    --      "down",
    --      "down_red"
    --    }
    local population_arrow_ui_component = UIComponent(this:Find("population_arrow"))
    --    population_arrow_ui_component:SetState(states[battle_details.PopulationChange + 1])
    population_arrow_ui_component:SetVisible(false)
    local cash_arrow_ui_component = UIComponent(this:Find("cash_arrow"))
    --    cash_arrow_ui_component:SetState(states[battle_details.WealthChange + 1])
    cash_arrow_ui_component:SetVisible(false)
    local upper_class_reaction_icon_ui_component = UIComponent(this:Find("upper_class_reaction_icon", true))
    if battle_details.is_major_battle then
        mach_lib.update_mach_lua_log('Is Major Battle, showing major battle pip.')
        local major_battle_image = UIImage("data/ui/campaign ui/skins/post_army.tga")
        major_battle_image:SetComponentTexture(upper_class_reaction_icon_ui_component:Address(), 0)
        upper_class_reaction_icon_ui_component:SetState("Neutral")
--        upper_class_reaction_icon_ui_component:SetTooltipText("Battle is major battle.", true)
        upper_class_reaction_icon_ui_component:SetVisible(true)
    else
        upper_class_reaction_icon_ui_component:SetVisible(false)
    end

    --    upper_class_reaction_icon_ui_component:LuaCall("init_state_from_value", battle_details.UpperOrder)
    local lower_class_reaction_icon_ui_component = UIComponent(this:Find("lower_class_reaction_icon", true))
    if battle_details.is_naval_battle then
        mach_lib.update_mach_lua_log('Is Naval Battle, showing naval battle pip.')
        local naval_battle_image = UIImage("data/ui/campaign ui/skins/post_navy.tga")
        naval_battle_image:SetComponentTexture(lower_class_reaction_icon_ui_component:Address(), 0)
        lower_class_reaction_icon_ui_component:SetState("Angry")
--        lower_class_reaction_icon_ui_component:SetTooltipText("Battle is naval battle.", true)
        lower_class_reaction_icon_ui_component:SetVisible(true)
    elseif battle_details.is_siege then
        mach_lib.update_mach_lua_log('Is Siege, showing siege pip.')
        if battle_details.is_settlement_siege then
            mach_lib.update_mach_lua_log('Is settlement siege.')
            capital_dy_ui_component:SetStateText(battle_details.besieged_settlement_name)
        else
            mach_lib.update_mach_lua_log('Is fort siege.')
            capital_dy_ui_component:SetStateText(battle_details.besieged_fort_name)
        end
        local siege_battle_image = UIImage("data/ui/campaign ui/skins/prebat_button_hold_siege_unselected.tga")
        siege_battle_image:SetComponentTexture(lower_class_reaction_icon_ui_component:Address(), 0)
        lower_class_reaction_icon_ui_component:SetState("Angry")
        lower_class_reaction_icon_ui_component:SetVisible(true)
    else
        lower_class_reaction_icon_ui_component:SetVisible(false)
    end

    local coins_ui_component = UIComponent(this:Find("coins", true))
    coins_ui_component:SetVisible(false)
    UIComponent(this:Find("capital icon")):SetVisible(false)
    mach_lib.update_mach_lua_log(string.format('Finished processing battle "%s" for row_template_region.', battle_details.battle_name))
end
function LessThan(c, column)
  local rhs_value = UIComponent(c):GlobalExists("sort_columns")[column + 1]
  return column ~= 0 and sort_columns[column + 1] == rhs_value and sort_columns[1] < UIComponent(c):GlobalExists("sort_columns")[1] or rhs_value > sort_columns[column + 1]
end
function Region()
  return m_region
end
function Initialise(details, is_battle)
  mach_lib.update_mach_lua_log("Initializing row_template_region")
  is_battle = is_battle or false
  if not is_battle then
        __battle_details__ = nil
        mach_lib.update_mach_lua_log(string.format('Processing region for row_template_region'))
        if m_settlement_interface == nil then
            m_settlement_interface = CampaignSettlement(details.SettlementAddress)
            this:SetEventCallback("OnDestroyed", OnDestroyed)
            mach_lib.update_mach_lua_log(m_settlement_interface)
        end
        mach_lib.update_mach_lua_log(tostring(details.SettlementAddress))
        mach_lib.update_mach_lua_log(tostring(m_settlement_interface))

        details = m_settlement_interface:ListDetails()
        mach_lib.update_mach_lua_log(string.format('Processing region "%s" for row_template_region', details.Name))
        m_region = details.Address
        sort_columns = {
          details.Name,
          details.PopulationNumber,
          details.UpperOrder,
          details.Wealth
        }
        local c = UIComponent(this:Find("region_dy"))
        c:SetStateText(details.Name, true, 2)
        c = UIComponent(this:Find("capital_dy"))
        c:SetStateText(details.Settlement)
        c = UIComponent(this:Find("population"))
        c:SetStateText(details.Population)
        c = UIComponent(this:Find("percentage"))
        c:SetStateText(string.format("%.1f", (details.UpperTax + details.LowerTax) * 100) .. "%")
        c = UIComponent(this:Find("money"))
        c:SetStateText(details.Wealth)
        local states = {
          "up",
          "up",
          "up",
          "down",
          "down_red"
        }
        c = UIComponent(this:Find("population_arrow"))
        c:SetState(states[details.PopulationChange + 1])
        c:SetVisible(details.PopulationChange ~= 2)
        c = UIComponent(this:Find("cash_arrow"))
        c:SetState(states[details.WealthChange + 1])
        c:SetVisible(details.WealthChange ~= 2)
        c = UIComponent(this:Find("upper_class_reaction_icon", true))
        c:LuaCall("init_state_from_value", details.UpperOrder)
        c = UIComponent(this:Find("lower_class_reaction_icon", true))
        c:LuaCall("init_state_from_value", details.LowerOrder)
        UIComponent(this:Find("capital icon")):SetVisible(details.IsCapital)
  else
      _populate_row_template_with_battle(details)
  end
  mach_lib.update_mach_lua_log("Finished initializing row_template_region.")
end
function OnRClickUp()
    if not __battle_details__ then
        mach_lib.update_mach_lua_log("Right clicked on region row, showing region details pop-up.")
        Component.CallByAddress(Component.Root(), "LuaCall", "ShowRegionInfo", m_region)
    else
        mach_lib.update_mach_lua_log("Right clicked on battle row, showing battle details message.")
        local message_auto_show = true
        mach_lib.show_message_box(message_auto_show, __battle_details__.message_screen_height, __battle_details__.message_screen_width, __battle_details__.message_icon, __battle_details__.message_text, __battle_details__.message_event, __battle_details__.message_image, __battle_details__.message_title, __battle_details__.message_data, __battle_details__.message_layout, __battle_details__.message_requires_response)
    end
end
function OnDestroyed()
  if m_settlement_interface ~= nil then
    m_settlement_interface:Release()
  end
end
function NotifySettlementUpdated()
  Initialise(m_settlement_interface:ListDetails())
end
