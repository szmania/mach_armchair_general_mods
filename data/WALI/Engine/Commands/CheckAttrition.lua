--[[
Description:
	Checks if the current location is an attrition location.  Note that this not return anything - the results of the check
	are wrote, by WALI, to a seperate return file (interface/WL) which must be manually checked.
	Attrition areas are defined in the attrition map located in Engine/Maps

Arguments:
	Number x
		X co-ordinate to check

	Number y
		Y co-ordinate to check

	String optionalHeader
		Optional string that will be appended to the top of the .WALI file being created.
		Can be left empty
Returns:
	n/a
--]]
function CheckAttritionLocation(x, y, optionalHeader)
	if type(x) ~= "nil" and type(x) == "number" and type(y) ~= "nil" and  type(y) == "number" then
		CreateWALIInterfaceLog(nil, "CHECK_ATTRITION", math.floor(x)..";"..math.floor(y), optionalHeader)
	else
		UpdateWALILuaLog("Attrition check failed.\n\tX: "..tostring(x).." Y: "..tostring(y).." C: "..tostring(optionalHeader))
	end
end