--[[
Description:
	Changes a unit's maximum size (ie the size it will replenish to)
Arguments:
	Number(hex) base_pointer
		Memory pointer to the current unit - cannot be in hex annotated format,
		e.g  0x001EF35A = incorrect, 001EF35A = correct

	Number command_argument
		Size to set unit maximum to

	String optionalHeader
		Optional string that will be appended to the top of the .WALI file being created.
		Can be left empty
Returns:
	n/a
--]]
function SetMaximumUnitSize(base_pointer, command_argument, optionalHeader)
	base_pointer = convertCAAddressToHexPointer(base_pointer)
	if type(base_pointer) ~= "nil" --[[and type(base_pointer) == "number"--]] and type(command_argument) ~= "nil" and  type(command_argument) == "number" then
		CreateWALIInterfaceLog(base_pointer, "SET_MAX_UNIT_SIZE", math.floor(command_argument), optionalHeader)
	end
end