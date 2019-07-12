using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace WALI_Engine
{
    /**
     *Deals specifically with attrition properties 
     */
    class Attrition
    {
        #region Attributes
        private string _name; //Description of the attrition. (Not sure why this is here? Daniel 15/06/13)
        private Color _colour;  //The colour used on the map to preresent it
        private string _type; // HEAT / COLD
        private string _season; // SUMMER / WINTER / ALL
        private int _returnVal;
        #endregion

        #region Constructors
        public Attrition(string name, Color colour, string type, string season, int returnVal)
        {
            _name = name;
            _colour = colour;
            _type = type;
            _season = season;
            _returnVal = returnVal;
        }
        #endregion

        #region Properties
        public string Name
        {
            get
            {
                return _name;
            }
            set
            {
                _name = value;
            }
        }

        public Color Colour
        {
            get
            {
                return _colour;
            }
            set
            {
                _colour = value;
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

        public string Season
        {
            get
            {
                return _season;
            }
            set
            {
                _season = value;
            }
        }

        public int ReturnValue
        {
            get
            {
                return _returnVal;
            }
            set
            {
                _returnVal = value;
            }
        }
        #endregion
    }
}
