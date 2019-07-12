.wcf commands should be formatted as follows:

Command name
Data Type
Offset
Is little endian?
Is engine managed?

where:

Command name is: The unique text keyword for this command. This will be used to 
identify the command when passed from Lua. Should be all one word, must start with a letter
Data Type is: The data type of the variable in memory to edit (byte, int, float, short, long etc). When dealing with numbers, most are ints
Offset is: The start byte of the data in memory, relative to the provided address.
Is little endian? is: Is the data little endian? (True/False) If you are unsure of this please google it, a wrong entry here will warp all commands and probably
crash the game
Is engine managed? is: Is the command managed by the engine exclusively (hardcoded)? (True/False) User made commands should be set to false

Please see other files for examples, there may not be complete error checking in place and,
as such, errors may occur from incorrect syntax

For the command to be useable by the engine, a lua implementation must also be provided.
See the docs fodler for information on this