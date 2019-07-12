wali = require "WALI/WALI"
--[[
Description:
	Get a unit's replenishable size.
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
function GetUnitReplenishable(base_pointer, optionalHeader)
	wali.UpdateWALILuaLog("GetUnitReplenishable - started")
	base_pointer = convertCAAddressToHexPointer(base_pointer)
	if type(base_pointer) ~= "nil" --[[and type(base_pointer) == "number" --]] then
		CreateWALIInterfaceLog(base_pointer, "GET_UNIT_REPLENISHABLE", optionalHeader)
		local unitReplenishableAmount =  readWALIReturnFile()
		wali.UpdateWALILuaLog("GetUnitReplenishable - contents returned: "..tostring(unitReplenishableAmount))
		return unitReplenishableAmount
	end
end
