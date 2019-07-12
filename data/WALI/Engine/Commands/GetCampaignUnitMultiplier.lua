wali = require "WALI/WALI"

--[[
Description:
	Get a campaign unit multiplier as shown in preferences.empire_script.txt
Arguments:
	Number(hex) base_pointer
		Memory pointer to the current unit - cannot be in hex annotated format,
		e.g  0x001EF35A = incorrect, 001EF35A = correct

	String optionalHeader
		Optional string that will be appended to the top of the .WALI file being created.
		 Can be left empty
Returns:
	n/a
--]]
function GetCampaignUnitMultiplier(optionalHeader)
    wali.UpdateWALILuaLog("GetCampaignUnitMultiplier started")
--    base_pointer = convertCAAddressToHexPointer(base_pointer)
--    mach_lib.update_mach_lua_log(base_pointer)
--    mach_lib.update_mach_lua_log(tostring(base_pointer))
    local base_pointer = '017F1C80'
--    local base_pointer = '0013F1C80'
    if type(base_pointer) ~= "nil" --[[and type(base_pointer) == "number" --]] then
        CreateWALIInterfaceLog(base_pointer, "GET_CAMPAIGN_UNIT_MULTIPLIER", optionalHeader)
        local campaign_unit_multiplier =  readWALIReturnFile()
        wali.UpdateWALILuaLog("GetCampaignUnitMultiplier - Campaign unit multiplier value: "..tostring(campaign_unit_multiplier))
        return campaign_unit_multiplier
    end
end
