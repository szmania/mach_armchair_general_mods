using System;
using System.Collections.Generic;
using System.Text;

namespace WALI_Engine
{
    /**
     * A generic WALI command. Each command is defined in the .wcf files under WALI/Engine/Commands. See the readme there for text based
     * formatting
     * **/
    class Command
    {
        #region Attributes
        //The unique text keyword for this command. This will be used to identify the command when passed from Lua
        private string _activator;  
        //The data type of the variable in memory to edit
        private string _type;
        //The start byte of the data in memory, relative to the provided address. i.e. the offset
        private int _startByte;
        //Is the data little endian?
        private bool _littleEndian;
        //is this command engine managed (hardcoded)? eg attrition.
        private bool _engineManaged;
        #endregion

        #region Constructors
        public Command(string activator, string type, int startByte, bool littleEndian, bool engineManaged)
        {
            _activator = activator;
            _type = type.ToLower();
            _startByte = startByte;
            _littleEndian = littleEndian;
            _engineManaged = engineManaged;
        }
        #endregion

        #region Properties
        public string Activator
        {
            get
            {
                return _activator;
            }
            set
            {
                _activator = value;
            }
        }

        public string Type
        {
            get
            {
                return _type;
            }
            set
            {
                _type = value;
            }
        }

        public int StartByte
        {
            get
            {
                return _startByte;
            }
            set
            {
                _startByte = value;
            }
        }

        public bool LitteEndian
        {
            get
            {
                return _littleEndian;
            }
            set
            {
                _littleEndian = value;
            }
        }

        public bool EngineManaged
        {
            get
            {
                return _engineManaged;
            }
            set
            {
                _engineManaged = value;
            }
        }
        #endregion
    }
}
