--[[
Description:
	Get a unit's alpha pointer. The alpha pointer points to the location of the UnitRecord, which is grabbed from the db tables. (unit_stats_land, etc..)
	Here you can find attributes like UnitRecord.Men, accuracy, morale, etc... 
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
function GetAlphaPointer(base_pointer, optionalHeader)
	base_pointer = convertCAAddressToHexPointer(base_pointer)
	if type(base_pointer) ~= "nil" --[[and type(base_pointer) == "number" --]] then
		CreateWALIInterfaceLog(base_pointer, "GET_ALPHA_POINTER", optionalHeader)
		local alphaPointer =  readWALIReturnFile()
		return alphaPointer
	end
end
