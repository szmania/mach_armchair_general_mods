--[[
Description:
	Sets a unit's replenishable size to the size provided - should be used in conjunction with SetCurrentUnitSize
	A unit that has has it's size changed by SetCurrentUnitSize will, by default, not be able to replenish. In order for a unit to be able
	to replenish it must be assigned a "replenish to" value (i.e. the units default size). This is done automatically by the game when
	damage is suffered normally (eg as a result of battle) but must be manually handled when using the SetCurrentUnitSize command
	To fix that, use this function to set the unit's "replenish to" value to the units max size. See the attrition implementation in WALI.lua
	for a useage example
Arguments:
	Number(hex) base_pointer
		Memory pointer to the current unit - cannot be in hex annotated format,
		e.g  0x001EF35A = incorrect, 001EF35A = correct

	Number command_argument
		Size to allow unit to replenish to. If a decimal is provided it will round down

	String optionalHeader
		Optional string that will be appended to the top of the .WALI file being created.
		 Can be left empty
Returns:
	n/a
--]]
function SetUnitReplenishable(base_pointer, command_argument, optionalHeader)
	base_pointer = convertCAAddressToHexPointer(base_pointer)
	if type(base_pointer) ~= "nil" --[[and type(base_pointer) == "number" --]]and type(command_argument) ~= "nil" and  type(command_argument) == "number" then
		CreateWALIInterfaceLog(base_pointer, "SET_UNIT_REPLENISHABLE",  math.floor(command_argument), optionalHeader)
	end
end
