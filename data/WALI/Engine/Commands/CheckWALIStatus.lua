--[[
Description:
	Checks if WALI is currently running.  Note that this not return anything - the results of the check
	are wrote, by WALI, to a seperate return file (interface/WL) which must be manually checked.

Arguments:
	String optionalHeader
		Optional string that will be appended to the top of the .WALI file being created.
		Can be left empty
Returns:
	n/a
--]]
function CheckWALIStatus(optionalHeader)
	CreateWALIInterfaceLog(nil, "CHECK_STATUS", "0;0", optionalHeader)
end
