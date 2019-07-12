using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace WALI_Engine
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new FormWALI(args));
        }
    }
}
