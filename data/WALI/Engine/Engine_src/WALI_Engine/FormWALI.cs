using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace WALI_Engine
{
    public partial class FormWALI : Form
    {
        #region VARIABLES
        List<string> args;

        private string dataPath;
        private string waliPath;
        private string enginePath;
        private string commandsPath;
        private string interfacePath;
        private string logsPath;
        private string mapsPath;
        private string configsPath;
        private string campaignsPath;

        private List<Command> commands = new List<Command>();

        private Process[] processes;
        private Process process = null;

        private Bitmap attritionMap;
        private List<Attrition> attritionTypes = new List<Attrition>();

        private int statBytesEdited = 0;
        private int statCommandsPerformed = 0;
        private int statErrors = 0;
        private int logs = 0;
        private int maxProcessWait = 10000;
        private Stopwatch stopwatch = new Stopwatch();
        private bool firstError = true;
        private int attritionCalls = 0;
        private bool URI2 = false;
        private bool URI3 = false;

        private bool noErrorLogging = true;
        private bool slowerLoopSpeed = false;
        private bool testMode = false;
        private bool fakeProcess = false;
        private bool fileLog = false;
        #endregion

        public FormWALI(string[] arguments)
        {
            InitializeComponent();

            args = new List<string>(arguments);
            //args.Add("Empire");
            args.Add("-FileLog");
            //args.Add("-FakeProcess");
        }
       
        /// <summary>
        /// Process program variables, finds process for hooking and loads commands
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormWALI_Load(object sender, EventArgs e)
        {
            stopwatch.Start();

            #region PATH SETUP
            string baseDir = Application.StartupPath;
            string arg = @"..\";

            if (URI2 == true)
            {
                arg = @"..\..\";
            }
            if (URI3 == true)
            {
                arg = @"..\..\..\";
            }

            Uri baseUri = new Uri(baseDir, UriKind.Absolute);
            Uri resolvedUri = new Uri(baseUri, arg);
            dataPath = resolvedUri.LocalPath;

            waliPath = dataPath + @"WALI\";
            enginePath = waliPath + @"Engine\";
            commandsPath = enginePath + @"Commands\";
            interfacePath = waliPath + @"Interface\";
            logsPath = waliPath + @"Logs\";
            mapsPath = enginePath + @"Maps\";
            configsPath = enginePath + @"Configs\";
            campaignsPath = dataPath + @"campaigns\";

            if (File.Exists(logsPath + "FileLog.txt"))
            {
                File.Delete(logsPath + "FileLog.txt");
            }

            LogWALI("//Wali_Engine.exe", waliPath);
            #endregion

            #region CLOSE EXISTING ENGINES
            // Find all existing WALI processes
            processes = Process.GetProcessesByName("WALI_Engine");

            for (int i = 1; i < processes.Length; i++)
            {
                // Kill the process
                processes[i].Kill();
                LogWALI(processes[i].Id.ToString(), "Killed a WALI process");
            }

            processes = null;
            #endregion

            #region PERFORM CHECKS
            if (File.Exists(interfacePath + "WL\\startup.txt"))
            {
                File.Delete(interfacePath + "WL\\startup.txt");
            }

            if (args.Count > 0)
            {
                if ((args.Contains("-NoErrorLogging")) || (args.Contains("NoErrorLogging")))
                {
                    // No error logging
                    noErrorLogging = false;
                }
                if ((args.Contains("-Performance")) || (args.Contains("Performance")))
                {
                    // Slower loop speed for performance
                    slowerLoopSpeed = true;
                }
                if ((args.Contains("-TestMode")) || (args.Contains("TestMode")))
                {
                    // Turn on testing mode
                    testMode = true;
                }
                if ((args.Contains("-FakeProcess")) || (args.Contains("FakeProcess")))
                {
                    // Fake the existance of the game process
                    fakeProcess = true;
                    buttonStop.Visible = true;
                }
                if ((args.Contains("-FileLog")) || (args.Contains("FileLog")))
                {
                    // Turn on file logging
                    fileLog = true;
                }
                if ((args.Contains("-URI2")) || (args.Contains("URI2")))
                {
                    URI2 = true;
                }
                if ((args.Contains("-URI3")) || (args.Contains("URI3")))
                {
                    URI3 = true;
                }

                // Try and find the process we were told to get by the Launcher. (1st Argument is the process to find)
                try
                {
                    if (fakeProcess == false)
                    {
                        //Loop in case the game process is slow to startup
                        for (int i = 0; i < maxProcessWait; i++)
                        {
                            processes = Process.GetProcessesByName(args[0]);

                            if (processes.Length > 0)
                            {
                                process = processes[0];
                                // Break the loop now we have our process
                                break;
                            }
                        }

                        // Check if we still couldn't manage to find the process
                        if (process == null)
                        {
                            // Couldn't find single instance of the process!
                            ErrorLog("Game instance of " + args[0] + " could not be found!");
                            MessageBox.Show("Game instance of " + args[0] + " could not be found!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            Application.Exit();
                        }
                    }
                }
                catch (Exception e1)
                {
                    ErrorLog(e1.Message + " (The argument was '" + args[0] + "', index 0, of " + args.Count + " arguments.) ");
                    MessageBox.Show(e1.Message + " (The argument was '" + args[0] + "', index 0, of " + args.Count + " arguments.)", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    Application.Exit();
                }
            }
            else
            {
                // No arguments were passed to the program! We can't do anything now so exit.
                ErrorLog("No arguments passed to Engine!");
                MessageBox.Show("No arguments passed to Engine!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }
            #endregion

            #region LOAD FILES
            LoadCommandFiles();
            WriteManifest();
            ReadAttritionConfig();

            if (File.Exists(mapsPath + "attrition.png") == true)
            {
                attritionMap = new Bitmap(mapsPath + "attrition.png");
                LogWALI(mapsPath + "attrition.png", "Loading Attrition Map");
            }
            #endregion
        }

        private void FormWALI_Shown(object sender, EventArgs e)
        {
            timerStats.Enabled = true;

            //Delete all old files in the interface directory
            List<string> oldfiles = LoadFilesInFolder(interfacePath + @"LW\", "wali");
            foreach (string f in oldfiles)
            {
                if (Path.GetFileName(f) != "interface.wali")
                {
                    File.Delete(f);
                }
            }

            oldfiles = LoadFilesInFolder(interfacePath + @"WL\", "return");
            foreach (string f in oldfiles)
            {
                File.Delete(f);
            }

            MainLoop();
            stopwatch.Stop();
            timerStats.Enabled = false;
            DisplayWALIStats();
        }

        /// <summary>
        /// The main loop
        /// </summary>
        private void MainLoop()
        {
            // Loop endlessly until we exit the Main Loop
            while (true)
            {
                // If we want to fake the game process then we need to allow a way out
                // Our way out will be buttonStop, so we need to allow events to use it
                if (fakeProcess == false)
                {
                    // Make sure a process has been attached to the process variable
                    if (process != null)
                    {
                        // Check if the game process has exited
                        if (process.HasExited == true)
                        {
                            // Exit the main loop
                            return;
                        }
                    }
                    else
                    {
                        return;
                    }
                }
                else
                {
                    // Allowing form events during the loop
                    Application.DoEvents();
                }

                // Find every .wali file currently in the interface folder and process them
                List<string> files = LoadFilesInFolder(interfacePath + @"LW\", "wali");
                if (files.Count > 0)
                    ProcessAllWALIFiles(files);
                
                if (slowerLoopSpeed == true)
                {
                    System.Threading.Thread.Sleep(200);
                }
            }
        }

        /// <summary>
        /// Process a memory command
        /// </summary>
        /// <param name="lines">Array of lines from the .wali file</param>
        /// <param name="lines">.wali file name</param>
        /// <returns>blank string for success, else string with error details</returns>
        private string ProcessCommand(string[] lines, string file)
        {
            //return string holding error info, if any
            string errString = "";
            //declaring command name here to keep it visible
            string commandName = "";
            //Has the command been matched to a valid one?
            bool commandMatched = false;

            //Line 0 is a comment, so check that line 1 is good
            if ((lines[1] != "") && (lines[1] != null))
            {
                LogWALI(file, "Read Success (" + lines[1] + ")");
                // Split the command into the relevant pieces
                string[] pieces = lines[1].Split(';');

                // There must be at least 3 pieces - Address/Command/Value
                if (pieces.Length >= 3)
                {
                    LogWALI(file, "Expects command in format: Address/Command/Value");
                    string address = pieces[0];
                    commandName = pieces[1];
                    string value = "";

                    // Put the extra pieces of the value into a single variable
                    for (int p = 2; p < pieces.Length; p++)
                    {
                        value = value + pieces[p];

                        if (p < pieces.Length - 1)
                        {
                            value = value + "/";
                        }
                    }
                    LogWALI(file, "Sorted extra values (" + value + ")");

                    //Deal with the command
                    foreach (Command cmd in commands)
                    {
                        // Check if the command is known to WALI
                        if (commandName.Equals(cmd.Activator))
                        {
                            LogWALI(file, "Command activator matched: " + cmd.Activator);
                            commandMatched = true;
                            // Check if the command is managed by the engine
                            // If so we need to find out what function to perform
                            if (cmd.EngineManaged == true)
                            {
                                if (cmd.Activator.Equals("CHECK_STATUS"))
                                {
                                    statCommandsPerformed++;
                                    // We're here so everything is OK
                                    NotifyOfStatus();
                                }
                                else if (cmd.Activator.Equals("CHECK_ATTRITION"))
                                {
                                    // If this is our first attrition command, make sure we have attrition objects
                                    if (attritionCalls == 0)
                                    {
                                        attritionCalls++;

                                        // Must be at least one attrition type
                                        if (attritionTypes.Count < 1)
                                        {
                                            ErrorLog("There was a CHECK_ATTRITION call but there were no attrition objects!");
                                            TellLUA("0"); // Tell Lua NO so everything doesn't break
                                            attritionCalls = 0; // This will cause this validation to be made again
                                            break;
                                        }
                                    }

                                    Color colourOut;
                                    Point pixelOut;
                                    int returnVal = -1;
                                    bool inAttrition = CheckAttrition(value, out returnVal, out colourOut, out pixelOut);
                                    LogWALI(file, cmd.Activator + " (Result = " + inAttrition.ToString() + " / Pixel = " + pixelOut.X + "-" + pixelOut.Y + "/ Return Value = " + returnVal + "):");

                                    if (inAttrition == true)
                                    {
                                        // Output the return value to LUA.
                                        TellLUA(returnVal.ToString());
                                    }
                                    else
                                    {
                                        TellLUA("0");
                                    }
                                    break;
                                }
                                //COMMENTED OUT AS I FOUND A BETTER SOLUTION
                                //MACHIAVELLI
                                /*
                                else if (cmd.Activator.Equals("GET_ALPHA_POINTER"))
                                {
                                    string alphaPointer;
                                    int bytesRead;
                                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;
                                    byte[] buffer = ReadMemory(memoryPosition, 4, out bytesRead);
                                    
                                    if (BitConverter.IsLittleEndian)
                                        Array.Reverse(buffer);

                                    alphaPointer = BitConverter.ToString(buffer).Replace("-", "");
                                    
                                    TellLUA(alphaPointer);
                                    

                                    break;
                                     
                                }
                                else if (cmd.Activator.Equals("GET_UNIT_REPLENISHABLE"))
                                {
                                    int unitReplenishableAmount;
                                    //string unitReplenishableAmount;
                                    int bytesRead;
                                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;
                                    byte[] buffer = ReadMemory(memoryPosition, sizeof(int), out bytesRead);

                                    if (BitConverter.IsLittleEndian)
                                        Array.Reverse(buffer);

                                    string replenishStr = BitConverter.ToString(buffer).Replace("-", "");
                                    //unitReplenishableAmount = BitConverter.ToInt32(buffer, 0);

                                    unitReplenishableAmount = int.Parse(replenishStr, System.Globalization.NumberStyles.HexNumber);
                                    TellLUA(unitReplenishableAmount.ToString());
                                    //TellLUA(unitReplenishableAmount);

                                    break;
                                }

                                */
                                
                            }
                            else
                            //the command is not engine managed
                            {
                                // Perform the command
                                int bytesEdited;
                                LogWALI(file, cmd.Activator + " (Calling)");
                                bool complete = PerformCommand(cmd, address, value, file, out bytesEdited);
                                LogWALI(file, cmd.Activator + " (Success:" + complete + ")");

                                if (complete == false)
                                {
                                    //the command failed
                                    statErrors++;
                                    ErrorLog("Command Failure: " + commandName);
                                    errString = "Command Failure: " + commandName;
                                }
                                else
                                {
                                    // The command succeeded
                                    statCommandsPerformed++;
                                }
                                break;
                            }
                        }
                    }
                }
                else
                {
                    // There aren't at least 3 pieces, can't continue
                    statErrors++;
                    ErrorLog("Invalid Command; does not consist of three pieces");
                    errString = "Invalid Command; does not consist of three pieces";
                }
            }
            else
            {
                //Line 1 is either null or blank
                statErrors++;
                errString = "Invalid file formatting - entry on line 1 (zero indexed) is balnck string or null";
            }

            //if the command did not match and there has been no other errors yet, return this error
            if (!commandMatched && errString.Equals(""))
            {
                errString = "Command " + commandName + " not matched!";
            }
            return errString;
        }

        /// <summary>
        /// Process all of the WALI fiels in the directory
        /// </summary>
        /// <param name="files">The list of files in the directory</param>
        private void ProcessAllWALIFiles(List<string> files)
        {
            // Loop through every file and process each one
            foreach (string file in files)
            {
                LogWALI(file, "Registered");
                bool fileUsed = false;

                // Get the file info on the file we want to use
                FileInfo fileInfo = new FileInfo(file);
                bool fileInUse = IsFileLocked(fileInfo);

                // Allow a timeout
                Stopwatch accessTimeout = new Stopwatch();
                accessTimeout.Start();

                LogWALI(file, "Checking if file is in use...");

                // Wait until the file is not in use
                while (fileInUse == true)
                {
                    if (stopwatch.Elapsed.Seconds < 10)
                    {
                        System.Threading.Thread.Sleep(1);
                        fileInUse = IsFileLocked(fileInfo);
                    }
                    else
                    {
                        LogWALI(file, "Failed - File locked by Lua for too long");

                        // Check if this failed file already exists to prevent
                        // an error when trying to rename the new file
                        if (File.Exists(file + ".Fail"))
                        {
                            File.Delete(file + ".Fail");
                        }

                        File.Move(file, file + ".Fail");
                        break;
                    }
                }
                accessTimeout.Stop();
                LogWALI(file, "File not locked");

                LogWALI(file, "Attempting Read...");
                // Open the file
                string[] lines = null;
                if (File.Exists(file))
                {
                    lines = System.IO.File.ReadAllLines(file);
                }
                else
                {
                    ErrorLog("WALI tried to open " + Path.GetFileName(file) + " but it didn't exist!");
                    LogWALI(file, "Failed - File didn't exist on read");
                }

                // Process the command. If theres an error it will be stored in result
                string result = ProcessCommand(lines, file);

                if (result.Equals(""))
                {
                    fileUsed = true;
                }
                // Delete the now processed file or
                // keep it as an failed file if it wasn't used
                if (fileUsed == true)
                {
                    LogWALI(file, "Deleting");
                    File.Delete(file);
                }
                else
                {
                    LogWALI(file, "Failed: " + result);
                    File.Move(file, file + ".Fail");
                }
            }
        }
        
        /// <summary>
        /// Output a file to so that the LUA can read it
        /// </summary>
        /// <param name="output">Files content</param>
        private void TellLUA(string output)
        {
            StreamWriter sw = null;
            try
            {
                Stopwatch timeout = new Stopwatch();
                timeout.Start();

                // Waiting for LUA to deal with the file!
                while (File.Exists(interfacePath + @"WL\output.return") == true)
                {
                    if (stopwatch.Elapsed.Seconds > 10)
                    {
                        // Over 10 has passed and Lua still hasn't dealt with the file!
                        ErrorLog("LUA didn't deal with output.return in time");
                        File.Delete(interfacePath + @"WL\output.return");
                        break;
                    }
                }

                sw = new StreamWriter(interfacePath + @"WL\output.return", true);

                LogWALI(interfacePath + @"WL\output.return", "WALI Output (Contents=" + output + ")");
                sw.Write(output);
                sw.Flush();
            }
            catch (Exception e)
            {
                ErrorLog(e.Message + " (Output attempted: " + output + " )");
            }
            finally
            {
                if (sw != null)
                {
                    sw.Dispose();
                    sw.Close();
                }
            }
        }

        /// <summary>
        /// Peforms a command with provided data
        /// </summary>
        /// <param name="cmd">The command object to use</param>
        /// <param name="address">The memory address to work at</param>
        /// <param name="value">The value to work with</param>
        /// <param name="file">The .WALI file it is processing</param>
        /// <returns></returns>
        private bool PerformCommand(Command cmd, string address, string value, string file, out int bytesEdited)
        {
            //10/08/2012: Int32.Parse wasn't provided the correct args, causing it to trip over hex numbers
            //Added System.Globalization.NumberStyles.HexNumber to fix this.
            LogWALI(file, "PerformCommand called, arguments: " + address + ", " + value + ", " + file);

            bool worked = false;
            bytesEdited = 0;
            //MACHIAVELLI
            //added ability to get values if the lua function begins with the word "get"

            if (cmd.Activator.StartsWith("get", System.StringComparison.CurrentCultureIgnoreCase))
            {
                //this part returns int32
                if ((cmd.Type == "int") || (cmd.Type == "integer") || (cmd.Type == "int32")) // 4 Bytes
                {
                    int returnValue;

                    int bytesRead;
                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;
                    byte[] buffer = ReadMemory(memoryPosition, sizeof(int), out bytesRead);

                    if (BitConverter.IsLittleEndian)
                        Array.Reverse(buffer);

                    string tempStr = BitConverter.ToString(buffer).Replace("-", "");
                    //unitReplenishableAmount = BitConverter.ToInt32(buffer, 0);

                    returnValue = int.Parse(tempStr, System.Globalization.NumberStyles.HexNumber);
                    LogWALI(file, "Integer value returned: " + returnValue.ToString());
                    TellLUA(returnValue.ToString());
                    worked = true;

                }
                //this part returns pointers
                else if (cmd.Type.IndexOf("pointer", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    string returnPointer;
                    int bytesRead;
                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;
                    byte[] buffer = ReadMemory(memoryPosition, 4, out bytesRead);
                                    
                    if (BitConverter.IsLittleEndian)
                                        Array.Reverse(buffer);

                    returnPointer = BitConverter.ToString(buffer).Replace("-", "");

                    LogWALI(file, "Returned pointer: " + returnPointer.ToString());
                    TellLUA(returnPointer.ToString());
                    worked = true;
                }
                else if (cmd.Type == "float") // 4 Bytes
                {
                    LogWALI(file, "Getting \"float\" type for value address space at address: " + address.ToString());

                    float returnValue;
                    int bytesRead;
                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;
                    byte[] buffer = ReadMemory(memoryPosition, sizeof(float), out bytesRead);
                    if (BitConverter.IsLittleEndian)
                        Array.Reverse(buffer);

                    //string tempStr = BitConverter.ToString(buffer).Replace("-", "");

                    returnValue = BitConverter.ToSingle(buffer, 0);
                    //LogWALI(file, "tempFloat: " + returnValue.ToString());
                    //unitReplenishableAmount = BitConverter.ToInt32(buffer, 0);

                    //returnValue = float.Parse(tempStr, System.Globalization.NumberStyles.HexNumber);
                    LogWALI(file, "Float return value: " + returnValue.ToString());
                    TellLUA(returnValue.ToString());
                    worked = true;
                }
            }
            else
            {

                if (cmd.Type == "byte") // 1 Byte
                {
                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;

                    worked = WriteMemory(memoryPosition, long.Parse(value), out bytesEdited);
                }
                else if (cmd.Type == "short") // 2 Bytes
                {
                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;

                    short valueShort;
                    bool parsed = short.TryParse(value, out valueShort);

                    if (parsed == false)
                        return false;

                    byte[] byteArray = BitConverter.GetBytes(valueShort);

                    worked = WriteByteArray(memoryPosition, byteArray, out bytesEdited);
                }
                else if ((cmd.Type == "int") || (cmd.Type == "integer") || (cmd.Type == "int32")) // 4 Bytes
                {
                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;

                    int valueInt;
                    bool parsed = Int32.TryParse(value, out valueInt);

                    if (parsed == false)
                        return false;

                    byte[] byteArray = BitConverter.GetBytes(valueInt);

                    worked = WriteByteArray(memoryPosition, byteArray, out bytesEdited);
                }
                else if (cmd.Type == "long") // 8 Bytes
                {
                    int memoryPosition = Int32.Parse(address, System.Globalization.NumberStyles.HexNumber) + cmd.StartByte;

                    long valueLong;
                    bool parsed = long.TryParse(value, out valueLong);

                    if (parsed == false)
                        return false;

                    byte[] byteArray = BitConverter.GetBytes(valueLong);

                    worked = WriteByteArray(memoryPosition, byteArray, out bytesEdited);
                }
            }
            return worked;
        }

        /// <summary>
        /// Loads the .wcf command files from the relevant directory
        /// </summary>
        private void LoadCommandFiles()
        {
            //Find all the command filesi n the directory and loop through them
            List<string> cmdFiles = LoadFilesInFolder(commandsPath, "wcf");

            foreach (string cmdFile in cmdFiles)
            {
                if (File.Exists(cmdFile))
                {
                    try
                    {
                        string[] lines = File.ReadAllLines(cmdFile);
                        LogWALI(cmdFile, "Reading WCF");

                        string activator = lines[0];
                        string type = lines[1];
                        int startByte = int.Parse(lines[2]);
                        bool littleEndian = bool.Parse(lines[3]);
                        bool engineManaged = bool.Parse(lines[4]);

                        Command newCommand = new Command(activator, type, startByte, littleEndian, engineManaged);
                        commands.Add(newCommand);
                    }
                    catch (Exception e)
                    {
                        ErrorLog(e.Message + " (Command File Failure: " + Path.GetFileNameWithoutExtension(cmdFile) + ")");
                        MessageBox.Show(e.Message + " (Command File Failure: " + Path.GetFileNameWithoutExtension(cmdFile) + ")", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        Application.Exit();
                    }
                }
            }
        }

        /// <summary>
        /// Find all Lua files in command folder and add them to a manifest if they have a corresponding wcf file
        /// </summary>
        private void WriteManifest()
        {
            List<string> cmdLuas = LoadFilesInFolder(commandsPath, "lua");

            foreach (string file in cmdLuas)
            {
                // Does this Lua file have a corresponding wcf file?
                if (File.Exists(commandsPath + Path.GetFileNameWithoutExtension(file) + ".wcf") == false)
                {
                    ErrorLog(Path.GetFileName(file) + " wasn't added to manifest (Did not have corresponding wcf file)");

                    // Remove from the list so it doesn't get written to the manifest
                    cmdLuas.Remove(file);
                }
            }

            // If a manifest already exists, delete it
            if (File.Exists(commandsPath + "manifest.txt") == true)
            {
                File.Delete(commandsPath + "manifest.txt");
            }

            // Write a new manifest
            StreamWriter sw = new StreamWriter(commandsPath + "manifest.txt", true);

            foreach (string file in cmdLuas)
            {
                sw.WriteLine(Path.GetFileName(file));
                sw.Flush();
            }

            if (sw != null)
            {
                sw.Dispose();
                sw.Close();
            }
        }

        /// <summary>
        /// Finds all files with a given extension in a given directory
        /// </summary>
        /// <param name="path">Directory to search</param>
        /// <param name="fileType">Extension of files to search for (No '.')</param>
        /// <returns>List of file paths</returns>
        private List<string> LoadFilesInFolder(string path, string fileType)
        {
            List<string> fileList = new List<string>();

            DirectoryInfo dir = new DirectoryInfo(path);

            try
            {
                FileInfo[] fileListTemp = dir.GetFiles("*." + fileType);

                foreach (FileInfo f in fileListTemp)
                {
                    if (f.Name != "interface.wali")
                    {
                        fileList.Add(f.FullName);
                    }
                }
            }
            catch (Exception e)
            {
                ErrorLog(e.Message);
                MessageBox.Show("Error occured trying to load a file: \n" + e.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }

            return fileList;
        }

        /// <summary>
        /// Writes to FileLog.txt, includes information about all .wali lifecycles
        /// </summary>
        /// <param name="file">Name of the .wali file</param>
        /// <param name="extra">Information pertaining to event</param>
        private void LogWALI(string file, string extra = "")
        {
            if (fileLog == false) return;

            StreamWriter sw = null;
            try
            {
                logs++;
                sw = new StreamWriter(logsPath + "FileLog.txt", true);
                //Added fake process flag. Daniel 18/06/13
                string fakeFlag = "";
                if (fakeProcess)
                {
                    fakeFlag = "[Fake Process] ";
                }
                string timestamp = "[" + DateTime.Now.Hour + ":" + DateTime.Now.Minute + ":" + DateTime.Now.Second + ":" + DateTime.Now.Millisecond.ToString() + "] " + fakeFlag;

                if (logs == 1)
                {
                    sw.WriteLine(timestamp + "LOG START:-\n\n");
                }

                sw.WriteLine(timestamp + Path.GetFileName(file) + " - " + extra + "\n");
                sw.Flush();
            }
            catch (Exception e)
            {
                ErrorLog(e.Message);
                MessageBox.Show("There was a problem logging an WALI command:\n" + e.Message + "\n" + e.StackTrace, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }
            finally
            {
                if (sw != null)
                {
                    sw.Dispose();
                    sw.Close();
                }
            }
        }

        /// <summary>
        /// Checks if a file is currently locked by another program
        /// </summary>
        /// <param name="file">File to check</param>
        /// <returns>True if file is locked</returns>
        protected virtual bool IsFileLocked(FileInfo file)
        {
            FileStream stream = null;

            try
            {
                stream = file.Open(FileMode.Open, FileAccess.ReadWrite, FileShare.None);
            }
            catch (IOException)
            {
                //the file is unavailable because it is:
                //still being written to
                //or being processed by another thread
                //or does not exist (has already been processed)
                return true;
            }
            finally
            {
                if (stream != null)
                    stream.Close();
            }

            //file is not locked
            return false;
        }

        /// <summary>
        /// Function to check if the game process is responding (or running)
        /// </summary>
        /// <param name="kill">Optional - True if you want to kill non-responding game</param>
        /// <returns>True if game is responding</returns>
        private bool IsGameResponding(bool kill = false)
        {
            if (process == null) return false;

            bool responding = process.Responding;

            if (kill == true)
            {
                if (responding == false)
                {
                    process.Kill();
                }
            }

            return responding;
        }

        /// <summary>
        /// Writes current WALI stats to display
        /// </summary>
        private void DisplayWALIStats()
        {
            string elapsedTime = String.Format("{0:00}:{1:00}:{2:00}",
               stopwatch.Elapsed.Hours, stopwatch.Elapsed.Minutes, stopwatch.Elapsed.Seconds + 1);

            labelStats.Text = "Running Time: " + elapsedTime + " (HH:MM:SS)\n\r" +
                "Commands Performed: " + statCommandsPerformed.ToString() + "\n\r" +
                "Bytes Edited: " + statBytesEdited.ToString() + "\n\r" +
                "Errors: " + statErrors.ToString();

            Application.DoEvents();
        }

        /// <summary>
        /// Function to check if Steam is currently running
        /// </summary>
        /// <returns>True if Steam is running</returns>
        private bool IsSteamRunning()
        {
            Process[] procs = Process.GetProcessesByName("Steam");

            if (procs.Length < 1)
            {
                return false;
            }

            return true;
        }

        /// <summary>
        ///  Writes a file to notify Lua that WALI has successfuly started
        /// </summary>
        private void NotifyOfStatus()
        {
            StreamWriter file = new StreamWriter(interfacePath + "WL\\startup.txt");
            file.WriteLine("1");
            file.Close();
        }

        /// <summary>
        /// Function to test if a command will activate (will be used)
        /// </summary>
        /// <param name="commandLine">The full command to test</param>
        /// <returns>True if the command will activate</returns>
        private bool TestCommand(string commandLine)
        {
            bool willActivate = false;

            string[] pieces = commandLine.Split(';');

            if (pieces.Length >= 3)
            {
                string address = pieces[0];
                string command = pieces[1];
                string value = "";

                for (int p = 2; p < pieces.Length; p++)
                {
                    value = value + pieces[p];

                    if (p < pieces.Length - 1)
                    {
                        value = value + "/";
                    }
                }

                foreach (Command cmd in commands)
                {
                    if (command == cmd.Activator)
                    {
                        if (cmd.EngineManaged != null)
                        {
                            willActivate = true;
                        }
                    }
                }
            }

            return willActivate;
        }

        private void timerStats_Tick(object sender, EventArgs e)
        {
            DisplayWALIStats();
        }

        private void buttonStop_Click(object sender, EventArgs e)
        {
            buttonStop.Visible = false;
            fakeProcess = false;
        }

        #region ATTRITION MANAGEMENT
        /// <summary>
        /// Processes a CHECK_ATTRITION command
        /// </summary>
        /// <param name="value">The value(s) sent with the command</param>
        /// <param name="returnVal">The result (int) that will be sent to Lua</param>
        /// <param name="colour">The colour of the pixel</param>
        /// <param name="pixel">The pixel location</param>
        /// <returns>True if the sent location is in attrition</returns>
        private bool CheckAttrition(string value, out int returnVal, out Color colour, out Point pixel)
        {
            statCommandsPerformed++;
            string[] pieces = value.Split('/');

            pixel = new Point(9999,9999);
            bool isAttrition = false;
            colour = Color.Empty;
            returnVal = -1;

            // There must be two pieces, X and Y
            if (pieces.Length == 2)
            {
                // Step 1
                try
                {
                    pixel = GetPixelFromCoords(Int32.Parse(pieces[0]), Int32.Parse(pieces[1]));
                }
                catch (Exception e)
                {
                    ErrorLog(e.Message + " - Failed Attrition Check - Step 1 - (" + pieces[0] + "/" + pieces[1] + ")");
                    return false;
                }
                // Step 2
                try
                {
                    isAttrition = IsPixelAttrition(pixel, out returnVal);
                }
                catch (Exception e)
                {
                    ErrorLog(e.Message + " - Failed Attrition Check - Step 2 - (" + pieces[0] + "/" + pieces[1] + ")");
                    return false;
                }
            }

            return isAttrition;
        }

        /// <summary>
        /// Converst given coordinates into a pixel location
        /// </summary>
        /// <param name="coordX">X Coordinate</param>
        /// <param name="coordY">Y Coordinate</param>
        /// <returns>Point value containing pixel location</returns>
        private Point GetPixelFromCoords(int coordX, int coordY)
        {
            //these formulas are wrong, but so were mine. 
            //from now on ensure that attrition map = game map size, eg (vanilla) 2560X1280

            /*int pixelX = (attritionMap.Width / 2) + (coordX * (attritionMap.Width / 2560));
            int pixelY = (attritionMap.Height / 2) - (coordY * (attritionMap.Height / 1280));
            */

            // 11/07/2013 this formula still seems wrong as it is producing values that are off enough to cause problems
            int pixelX = (attritionMap.Width / 2) + coordX;
            int pixelY = (attritionMap.Height / 2) - coordY;
            return new Point(pixelX, pixelY);
        }

        /// <summary>
        /// Checks the colour of a pixel and compares it to known attrition colours
        /// </summary>
        /// <param name="pixel">Location of the pixel to check</param>
        /// <param name="returnVal">The return value of the attrition, -1 indicates none</param>
        /// <returns>Returns true if pixel is attrition</returns>
        private bool IsPixelAttrition(Point pixel, out int returnVal)
        {
            Color pixelColour = attritionMap.GetPixel(pixel.X, pixel.Y);

            foreach (Attrition atr in attritionTypes)
            {
                if (pixelColour.ToArgb() == atr.Colour.ToArgb())
                {
                    returnVal = atr.ReturnValue;
                    return true;
                }
            }

            returnVal = -1;
            return false;
        }

        /// <summary>
        /// Reads the Attrition.Config file and loads the Attritions objects
        /// </summary>
        private void ReadAttritionConfig()
        {
            string config = configsPath + "Attrition.WaliConfig";
            if (File.Exists(config))
            {
                try
                {
                    string[] lines = File.ReadAllLines(config);
                    LogWALI(config, "Reading Attrition Config");

                    foreach (string line in lines)
                    {
                        string[] pieces = line.Split(';');
                        string[] RGB = pieces[1].Split(',');

                        string name = pieces[0];
                        Color colour = Color.FromArgb(Int32.Parse(RGB[0]), Int32.Parse(RGB[1]), Int32.Parse(RGB[2]));
                        string type = pieces[2];
                        string season = pieces[3];
                        int returnVal = Int32.Parse(pieces[4]);

                        Attrition newAttrition = new Attrition(name, colour, type, season, returnVal);
                        attritionTypes.Add(newAttrition);
                    }
                }
                catch (Exception e)
                {
                    ErrorLog(e.Message + " (Attrition Config File Failure: " + Path.GetFileName(config) + ")");
                }
            }
        }
        #endregion

        #region ERROR LOGGING
        /// <summary>
        /// Logs an error in a text file
        /// </summary>
        /// <param name="message">The message to log</param>
        public void ErrorLog(string message)
        {
            if (noErrorLogging == false) return;

            statErrors++;
            StreamWriter sw = null;
            try
            {
                string sLogFormat = DateTime.Now.ToString() + " ==> ";

                sw = new StreamWriter(Application.StartupPath + "\\Error_Log.txt", true);

                if (firstError == true)
                {
                    sw.WriteLine("**** WALI START ****\n\r\n\r" + Path.GetFileName(Application.ExecutablePath) + ":-" + sLogFormat + message);
                    firstError = false;
                }
                else
                {
                    sw.WriteLine(Path.GetFileName(Application.ExecutablePath) + ":-" + sLogFormat + message);
                }

                sw.Flush();
            }
            catch (Exception e)
            {
                // Problem error logging
                MessageBox.Show("There was a problem logging an error:\n" + e.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }
            finally
            {
                if (sw != null)
                {
                    sw.Dispose();
                    sw.Close();
                }
            }
        }
        #endregion

        #region MEMORY FUNCTIONS
        /// <summary>
        /// Reads memory chunk of a given size at a given address
        /// </summary>
        /// <param name="address">Address to read from</param>
        /// <param name="numOfBytes">Number of bytes to read at the address</param>
        /// <param name="bytesRead">The bytes read</param>
        /// <returns></returns>
        public byte[] ReadMemory(int address, int numOfBytes, out int bytesRead)
        {
            IntPtr hProc = OpenProcess(ProcessAccessFlags.All, false, process.Id);

            byte[] buffer = new byte[numOfBytes];

            ReadProcessMemory(hProc, new IntPtr(address), buffer, numOfBytes, out bytesRead);
            return buffer;
        }

        /// <summary>
        /// Writes memory at a given address
        /// </summary>
        /// <param name="address">Address to write to</param>
        /// <param name="value">The value to write to memory</param>
        /// <param name="bytesWritten">The bytes written</param>
        /// <returns>Did write work</returns>
        public bool WriteMemory(int address, long value, out int bytesWritten)
        {
            try
            {
                IntPtr hProc = OpenProcess(ProcessAccessFlags.All, false, process.Id);

                byte[] val = BitConverter.GetBytes(value);

                bool worked = WriteProcessMemory(hProc, new IntPtr(address), val, (UInt32)val.LongLength, out bytesWritten);

                CloseHandle(hProc);

                return worked;
            }
            catch (Exception e)
            {
                ErrorLog(e.Message + " (Memory Write Failure/LongValue)");
                bytesWritten = -1;
                return false;
            }
        }

        /// <summary>
        /// Writes a byte array to a given memory address
        /// </summary>
        /// <param name="address">Address to write to</param>
        /// <param name="byteArray">The byte array to write to memory</param>
        /// <param name="bytesWritten">The bytes written</param>
        /// <returns>Did write work</returns>
        public bool WriteByteArray(int address, byte[] byteArray, out int bytesWritten)
        {
            try
            {
                IntPtr hProc = OpenProcess(ProcessAccessFlags.All, false, process.Id);

                bool worked = WriteProcessMemory(hProc, (IntPtr)address, byteArray, (UInt32)byteArray.LongLength, out bytesWritten);

                CloseHandle(hProc);

                return worked;
            }
            catch (Exception e)
            {
                ErrorLog(e.Message + " (Memory Write Failure/ByteArray)");
                bytesWritten = -1;
                return false;
            }
        }
        #endregion

        #region DLL IMPORT
        [Flags]
        public enum ProcessAccessFlags : uint
        {
            All = 0x001F0FFF,
            Terminate = 0x00000001,
            CreateThread = 0x00000002,
            VMOperation = 0x00000008,
            VMRead = 0x00000010,
            VMWrite = 0x00000020,
            DupHandle = 0x00000040,
            SetInformation = 0x00000200,
            QueryInformation = 0x00000400,
            Synchronize = 0x00100000
        }

        [DllImport("kernel32.dll")]
        private static extern IntPtr OpenProcess(ProcessAccessFlags dwDesiredAccess, [MarshalAs(UnmanagedType.Bool)] bool bInheritHandle, int dwProcessId);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out int lpNumberOfBytesWritten);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool ReadProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, [Out] byte[] lpBuffer, int dwSize, out int lpNumberOfBytesRead);

        [DllImport("kernel32.dll")]
        public static extern Int32 CloseHandle(IntPtr hProcess);
        #endregion
    }
}
