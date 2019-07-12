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
using Common;

namespace WALI_Launcher_ETW
{
    public partial class FormLauncer : Form
    {
        #region VARIABLES
        static string applicationDataPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        static string scriptPath = Path.Combine(applicationDataPath, @"The Creative Assembly\Empire\scripts");
        static string userEmpireScriptFilepath = Path.Combine(scriptPath, "user.empire_script.txt");

        string etwPath;
        string etwDataPath;

        int mm = 0;
        int mmChange = 10;
        bool mmShown = false;
        int mmFull;
        private bool firstError = true;

        // Packed Filepath -> List of PackFiles with that Packed Filepath (list.Count > 1 indicates a conflict)
        SortedDictionary<string, List<PackFile>> packedFileMap;

        // PackFile -> List of Packed Filepaths that are in conflict
        Dictionary<PackFile, List<string>> packFileConflictMap;

        #region VANILLA PACKS
        List<string> vanillaPackList = new List<string>()
        {
            "anim.pack",
            "battlepresets.pack",
            "battleterrain.pack",
            "boot.pack",
            "groupformations.pack",
            "local_en.pack",
            "main.pack",
            "models.pack",
            "movies.pack",
            "patch.pack",
            "patch_en.pack",
            "seasurfaces.pack",
            "sound_non_wavefile_data.pack",
            "sounds.pack",
            "sounds_animation_triggers.pack",
            "sounds_campaign.pack",
            "sounds_music.pack",
            "sounds_other.pack",
            "sounds_placeholder.pack",
            "sounds_sfx.pack",
            "subtitles.pack",
            "supertexture.pack",
            "terrain_templates.pack",
            "testdata.pack",
            "ui.pack",
            "ui_movies.pack",
            "voices.pack"
        };
        #endregion
        #endregion

        public FormLauncer()
        {
            InitializeComponent();
            mmFull = this.Height;
            this.Height = 236;
        }

        private void ModManagerForm_Load(object sender, EventArgs e)
        {
            Text = "W.A.L.I  v" + Application.ProductVersion + "  (Empire: Total War)";

            #region Modder Extras
            if (File.Exists(Application.StartupPath + "\\Launch\\icon.ico"))
            {
                this.Icon = new Icon(Application.StartupPath + "\\Launch\\icon.ico");
            }
            if (File.Exists(Application.StartupPath + "\\Launch\\desc.txt"))
            {
                string[] lines = File.ReadAllLines(Application.StartupPath + "\\Launch\\desc.txt");

                StringBuilder stringBuilder = new StringBuilder();
                bool skipFirst = true;
                foreach (string str in lines)
                {
                    if (skipFirst)
                    {
                        groupBoxDesc.Text = str;
                        skipFirst = false;
                    }
                    else
                    {
                        stringBuilder.Append(str + "\n\r");
                    }
                }

                labelInfo.Text = stringBuilder.ToString();
            }
            #endregion
        }

        private void ModManagerForm_Shown(object sender, EventArgs e)
        {
            // try to use saved path to Empire: Total War
            etwPath = Properties.Settings.Default.EmpireTotalWarPath;

            if (String.IsNullOrEmpty(etwPath) ||
                !Directory.Exists(etwPath))
            {
                // try to detect folder automatically
                etwPath = IOFunctions.GetEmpireTotalWarDirectory();

                if (String.IsNullOrEmpty(etwPath) ||
                    !Directory.Exists(etwPath))
                {
                    // make user find the path to Empire.exe (or quit the app)
                    while (findETWPathFolderBrowserDialog.ShowDialog() == DialogResult.OK)
                    {
                        if (File.Exists(Path.Combine(findETWPathFolderBrowserDialog.SelectedPath, "Empire.exe")))
                        {
                            etwPath = findETWPathFolderBrowserDialog.SelectedPath;
                            break;
                        }
                        MessageBox.Show("Empire.exe not found in that directory, please try again.", "Invalid directory", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }

                    if (String.IsNullOrEmpty(etwPath))
                    {
                        MessageBox.Show("Can't resolve path to Empire.exe; will quit now!", "No valid path", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        Close();
                        return;
                    }
                }
            }

            etwDataPath = Path.Combine(etwPath, "data");

            // save detected or user-selected path
            Properties.Settings.Default.EmpireTotalWarPath = etwPath;
            Properties.Settings.Default.Save();

            refreshHelpLabel();

            // enumerate profiles
            foreach (string profileFilepath in Directory.GetFiles(scriptPath, "profile.*.txt"))
            {
                profilesComboBox.Items.Add(Regex.Match(profileFilepath, @"profile\.(.+)\.txt").Groups[1].ToString());
            }

            if (profilesComboBox.Items.Contains("last used mods"))
                profilesComboBox.SelectedIndex = profilesComboBox.Items.IndexOf("last used mods");
            else
                fillModListView(null);
        }

        private void fillModListView(string profileName)
        {
            modListView.Items.Clear();
            modListView.CheckBoxes = !modListView.ShowGroups;

            packedFileMap = new SortedDictionary<string, List<PackFile>>();
            packFileConflictMap = new Dictionary<PackFile, List<string>>();

            var lastUsedMods = new List<KeyValuePair<string,bool>>();

            if(!String.IsNullOrEmpty(profileName))
                lastUsedMods = readProfile(profileName);

            // enumerate previously used mods to preserve order;
            // ignore any files which no longer exist
            foreach (var modEnabledPair in lastUsedMods)
            {
                string modPath = Path.Combine(etwDataPath, modEnabledPair.Key + ".pack");
                if (File.Exists(modPath))
                {
                    PackFile packFile = new PackFile(modPath);
                    if (packFile.Type == PackType.Boot)
                        continue;

                    foreach (PackedFile packedFile in packFile.FileList)
                    {
                        if (!packedFileMap.ContainsKey(packedFile.Filepath))
                            packedFileMap[packedFile.Filepath] = new List<PackFile>() { packFile };
                        else
                            packedFileMap[packedFile.Filepath].Add(packFile);
                    }

                    string[] itemArray =
                        new string[] { Path.GetFileNameWithoutExtension(modEnabledPair.Key), "", "", "" };

                    ListViewItem pack = new ListViewItem(itemArray,
                                                         getListViewGroupByPackType(packFile.Type));
                    pack.Tag = packFile;
                    pack.UseItemStyleForSubItems = false;
                    modListView.Items.Add(pack);
                    pack.Checked = modEnabledPair.Value;
                }
            }

            // enumerate any new pack files
            foreach (string file in Directory.GetFiles(etwDataPath, "*.pack"))
            {
                PackFile packFile = new PackFile(file);
                if (packFile.Type == PackType.Boot)
                    continue;

                if (!lastUsedModsContains(lastUsedMods, Path.GetFileNameWithoutExtension(file)))
                {
                    // build conflicting file map, conditionally ignoring vanilla packs
                    if (Properties.Settings.Default.ShowVanillaConflicts ||
                        !vanillaPackList.Contains(Path.GetFileName(file)))
                    {
                        foreach (PackedFile packedFile in packFile.FileList)
                        {
                            if (!packedFileMap.ContainsKey(packedFile.Filepath))
                                packedFileMap[packedFile.Filepath] = new List<PackFile>() { packFile };
                            else
                                packedFileMap[packedFile.Filepath].Add(packFile);
                        }
                    }

                    // insert the pack if "show all packs" is enabled or the pack is a mod
                    if (modListView.ShowGroups || packFile.Type == PackType.Mod)
                    {
                        string[] itemArray =
                            new string[] { Path.GetFileNameWithoutExtension(file), "", "", "" };

                        ListViewItem pack = new ListViewItem(itemArray,
                                                             getListViewGroupByPackType(packFile.Type));
                        pack.Tag = packFile;
                        pack.UseItemStyleForSubItems = false;
                        modListView.Items.Add(pack);
                    }
                }
            }

            // search packedFileMap for values with more than 1 pack file; these are conflicted files
            foreach (KeyValuePair<string, List<PackFile>> kvp in packedFileMap)
            {
                if (kvp.Value.Count > 1)
                    for (int i = 0; i < kvp.Value.Count; ++i)
                    {
                        if (!packFileConflictMap.ContainsKey(kvp.Value[i]))
                            packFileConflictMap[kvp.Value[i]] = new List<string>() { kvp.Key };
                        else
                            packFileConflictMap[kvp.Value[i]].Add(kvp.Key);
                    }
            }

            foreach (ListViewItem pack in modListView.Items)
                if (packFileConflictMap.ContainsKey(pack.Tag as PackFile))
                {
                    ListViewItem.ListViewSubItem conflictItem = pack.SubItems[3];
                    conflictItem.Font = new Font(modListView.Font, FontStyle.Underline);
                    conflictItem.ForeColor = Color.FromKnownColor(KnownColor.HotTrack);
                    conflictItem.Text = packFileConflictMap[pack.Tag as PackFile].Count.ToString() + " conflicts";
                }

            // auto-size columns from the collected metadata
            modListView.AutoResizeColumns(ColumnHeaderAutoResizeStyle.ColumnContent);
        }

        // returns the list view group for the given pack type
        private ListViewGroup getListViewGroupByPackType(PackType packType)
        {
            if (!modListView.ShowGroups)
                return null;

            switch (packType)
            {
                default:
                case PackType.Boot:
                    return null;

                case PackType.Release:
                    return modListView.Groups["releasePackGroup"];

                case PackType.Patch:
                    return modListView.Groups["patchPackGroup"];

                case PackType.Mod:
                    return modListView.Groups["modPackGroup"];

                case PackType.Movie:
                    return modListView.Groups["moviePackGroup"];
            }
        }

        // returns true if 'file' is one of the keys in 'lastUsedMods'
        private bool lastUsedModsContains(List<KeyValuePair<string, bool>> lastUsedMods, string file)
        {
            foreach (KeyValuePair<string, bool> pair in lastUsedMods)
                if (pair.Key == file)
                    return true;
            return false;
        }

        // gets everything but the "mod" lines
        private string getUserEmpireScriptWithoutMods()
        {
            StringBuilder userEmpireScript = new StringBuilder();
            if (File.Exists(userEmpireScriptFilepath))
            {
                string[] lines = File.ReadAllLines(userEmpireScriptFilepath, Encoding.Unicode);
                Regex regex = new Regex("^\\s*#?\\s*mod\\s+\"?(.+?)\"?\\s*;\\s*$");
                foreach (string line in lines)
                {
                    Match match = regex.Match(line);
                    if (!match.Success)
                        userEmpireScript.AppendLine(line);
                }
            }
            return userEmpireScript.ToString();
        }

        private int countModPacks()
        {
            int count = 0;

            for (int i = 0; i < modListView.Items.Count; ++i)
            {
                if ((modListView.Items[i].Tag as PackFile).Type == PackType.Mod)
                {
                    count++;
                }
            }
            return count;
        }

        private int countCheckedModPacks()
        {
            int count = 0;

            for (int i = 0; i < modListView.Items.Count; ++i)
            {
                if ((modListView.Items[i].Tag as PackFile).Type == PackType.Mod)
                {
                    if (modListView.Items[i].Checked)
                    {
                        count++;
                    }
                }
            }
            return count;
        }

        private bool scriptHasAnyMods()
        {
            if (File.Exists(userEmpireScriptFilepath))
            {
                string[] lines = File.ReadAllLines(userEmpireScriptFilepath, Encoding.Unicode);
                Regex regex = new Regex("^\\s*#?\\s*mod\\s+\"?(.+?)\"?\\s*;\\s*$");

                foreach (string line in lines)
                {
                    Match match = regex.Match(line);

                    if (match.Success)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        private void launchGameButton_Click(object sender, EventArgs e)
        {
            string nonModRelatedScriptText = getUserEmpireScriptWithoutMods();

            // We don't want to bother people who have no intention of using mod manager!
            if (mmShown == true)
            {
                int modPacks = countModPacks();
                int checkedModPacks = countCheckedModPacks();
                bool scriptHasMods = scriptHasAnyMods();

                // Are there any MOD packs? (MOD packs are the only relevant ones to us)
                if (modPacks > 0)
                {
                    // At least one checked mod pack means the user wants a script
                    if (checkedModPacks > 0)
                    {
                        using (StreamWriter writer = new StreamWriter(userEmpireScriptFilepath, false, Encoding.Unicode))
                        {
                            writeUserEmpireScript(writer, nonModRelatedScriptText);
                        }
                    }
                    else
                    {
                        // **** PROBLEMATIC SITUATION FROM FORCED USE OF MOD MANAGER ARRISES HERE **** -- suggestions?
                        // HERE WE NEED TO DECIDE IF THE USER LEFT EVERYTHING BLANK BECAUSE THEY WANTED A MODLESS USER.SCRIPT
                        // OR IF THEY ALREADY HAVE THEIR OWN PREVIOUSLY SETUP SCRIPT AND JUST WANT TO IGNORE MOD MANAGER

                        DialogResult result = MessageBox.Show("Your userscript is indicating that you have mods activated in it that are not selected here, is this intentional?", "Unknown intentions", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                        if (result == System.Windows.Forms.DialogResult.No)
                        {
                            result = MessageBox.Show("Would you like Mod Manager to remove the mods from that script for you?", "Help?", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                            if (result == System.Windows.Forms.DialogResult.Yes)
                            {
                                // Write a script like the user requested
                                using (StreamWriter writer = new StreamWriter(userEmpireScriptFilepath, false, Encoding.Unicode))
                                {
                                    writeUserEmpireScript(writer, nonModRelatedScriptText);
                                }
                            }
                        }
                    }
                }
                else
                {
                    // There are no mod packs, we want to make sure the userscript doesn't have any mods, so we'll write a new one nomatter what
                    using (StreamWriter writer = new StreamWriter(userEmpireScriptFilepath, false, Encoding.Unicode))
                    {
                        // Create a script without mods, but with the users other text.
                        writeUserEmpireScript(writer, nonModRelatedScriptText);
                    }
                }

                // store the mod list state as a profile
                writeProfile("last used mods");
            }

            // Launch WALI
            string waliCode = LaunchWALI();

            if (waliCode == "")
            {
                try
                {
                    // Launch Game
                    ProcessStartInfo startInfo = new ProcessStartInfo();
                    startInfo.FileName = Path.Combine(etwDataPath, "WALI\\Empire Total War.url");
                    Process.Start(startInfo);
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Empire.exe could not be launched!\n" + exc.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    ErrorLog(exc.Message);
                }
            }
            else
            {
                MessageBox.Show("W.A.L.I could not be launched!\n\nError: " + waliCode, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void writeUserEmpireScript(TextWriter writer, string nonModRelatedScriptText)
        {
            // enumerate items and set up the user.battle_script.txt file accordingly
            for (int i = 0; i < modListView.Items.Count; ++i)
            {
                // skip non-mod packs
                if ((modListView.Items[i].Tag as PackFile).Type != PackType.Mod)
                    continue;

                if (modListView.Items[i].Checked)
                    writer.Write("mod \"{0}.pack\";\r\n", modListView.Items[i].Text);
            }
            writer.Write(nonModRelatedScriptText);
        }

        private void moveUpButton_Click(object sender, EventArgs e)
        {
            // remove selected index, insert at index-1
            int selectedIndex = modListView.SelectedIndices[0];
            ListViewItem selectedItem = modListView.SelectedItems[0];
            bool wasChecked = modListView.Items[selectedIndex].Checked;
            modListView.Items.RemoveAt(selectedIndex);
            modListView.Items.Insert(selectedIndex - 1, (ListViewItem)selectedItem);
            modListView.Items[selectedIndex - 1].Checked = wasChecked;
            modListView.Items[selectedIndex - 1].Selected = true;
        }

        private void moveDownButton_Click(object sender, EventArgs e)
        {
            // insert at index+1, remove selected index
            int selectedIndex = modListView.SelectedIndices[0];
            ListViewItem selectedItem = modListView.SelectedItems[0];
            bool wasChecked = modListView.Items[selectedIndex].Checked;
            modListView.Items.Insert(selectedIndex + 2, (ListViewItem)selectedItem.Clone());
            modListView.Items.RemoveAt(selectedIndex);
            modListView.Items[selectedIndex + 1].Selected = true;
            modListView.Items[selectedIndex + 1].Checked = wasChecked;
        }

        private void modListView_SelectedIndexChanged(object sender, EventArgs e)
        {
            // refresh the button states
            // TODO: allow move up/down buttons with multiple selected rows
            moveUpButton.Enabled = !modListView.ShowGroups &&
                                   modListView.SelectedIndices.Count == 1 &&
                                   modListView.SelectedIndices[0] > 0;
            moveDownButton.Enabled = !modListView.ShowGroups &&
                                     modListView.SelectedIndices.Count == 1 &&
                                     modListView.SelectedIndices[0] < modListView.Items.Count - 1;
        }

        private void modListView_KeyDown(object sender, KeyEventArgs e)
        {
            e.Handled = true;
            if (e.KeyCode == Keys.Up && moveUpButton.Enabled)
                moveUpButton_Click(sender, e);
            else if (e.KeyCode == Keys.Down && moveDownButton.Enabled)
                moveDownButton_Click(sender, e);
            else
                e.Handled = false;
        }

        private void writeProfile(string profileName)
        {
            string userCustomEmpireScript = Path.Combine(scriptPath, "profile." + profileName + ".txt");
            using (StreamWriter writer = new StreamWriter(userCustomEmpireScript, false, Encoding.Unicode))
            {
                // enumerate checked boxes and set up the custom profile file accordingly

                foreach (ListViewItem item in modListView.Items)
                {
                    writer.Write("{1}{0}\n", item.Text, item.Checked ? "" : "#");
                }
            }
        }

        /// <summary>
        /// Read the named profile.
        /// </summary>
        /// <returns>A list of pairs naming the mods in the profile and whether they are enabled or not.</returns>
        private List<KeyValuePair<string, bool>> readProfile(string profileName)
        {
            string userCustomEmpireScript = Path.Combine(scriptPath, "profile." + profileName + ".txt");
            var modNameCheckedPairs = new List<KeyValuePair<string, bool>>();

            if (File.Exists(userCustomEmpireScript))
            {
                string[] profileLines = File.ReadAllLines(userCustomEmpireScript);

                foreach (string line in profileLines)
                {
                    if (line[0] == '#')
                        modNameCheckedPairs.Add(new KeyValuePair<string, bool>(line.TrimStart('#'), false));
                    else
                        modNameCheckedPairs.Add(new KeyValuePair<string, bool>(line, true));
                }
            }
            return modNameCheckedPairs;
        }

        private void saveProfileButton_Click(object sender, EventArgs e)
        {
            if (profilesComboBox.Text != "")
            {
                writeProfile(profilesComboBox.Text);
                if (!profilesComboBox.Items.Contains(profilesComboBox.Text))
                    profilesComboBox.Items.Add(profilesComboBox.Text);
            }
            else
            {
                MessageBox.Show("You must enter a name to save a profile.");
            }
        }

        private void deleteProfileButton_Click(object sender, EventArgs e)
        {
            if (profilesComboBox.Items.Contains(profilesComboBox.Text))
            {
                string userCustomEmpireScript = Path.Combine(scriptPath, "profile." + profilesComboBox.Text + ".txt");
                File.Delete(userCustomEmpireScript);
                profilesComboBox.Items.Remove(profilesComboBox.Text);
            }

        }

        private void profilesComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            fillModListView(profilesComboBox.Text);
        }

        private void profilesComboBox_TextChanged(object sender, EventArgs e)
        {
            deleteProfileButton.Enabled = profilesComboBox.Items.Contains(profilesComboBox.Text);
        }

        private void showAllPackTypesButton_Click(object sender, EventArgs e)
        {
            refreshHelpLabel();
            Properties.Settings.Default.Save();
            Properties.Settings.Default.Reload();
            fillModListView(profilesComboBox.Text);
        }

        private void showVanillaConflictsCheckBox_Click(object sender, EventArgs e)
        {
            Properties.Settings.Default.Save();
            Properties.Settings.Default.Reload();
            fillModListView(profilesComboBox.Text);
        }

        private void refreshHelpLabel()
        {
            if (showAllPackTypesCheckBox.Checked)
            {
                label1.Text = "The list is currently showing all pack files in your ETW data directory.\r\n" +
                              "\r\n" +
                              "Uncheck \"Show all pack types\" to enable or disable mods or change their load order.";
            }
            else
            {
                label1.Text = "The list is currently showing mod packs.\r\n" +
                              "Check the mods you want to use.\r\n" +
                              "Select a mod and press the arrows to change the load order of a mod pack.";
            }
            label1.Refresh();
        }

        private void modListView_MouseClick(object sender, MouseEventArgs e)
        {
            ListViewItem item = modListView.GetItemAt(e.X, e.Y);
            if (item != null)
            {
                ListViewItem.ListViewSubItem subitem = item.GetSubItemAt(e.X, e.Y);
                if (subitem == item.SubItems[3] && subitem.Text.Length > 0)
                {
                    Form form = new Form();
                    form.Text = "Conflicts for " + item.Text;
                    form.StartPosition = FormStartPosition.CenterParent;
                    form.WindowState = FormWindowState.Maximized;
                    DataGridView listView = new DataGridView();
                    listView.Columns.Add("packedFilepathColumn", "Packed Filepath");
                    listView.Columns.Add("conflictingPackFilesColumn", "Conflicting Pack Files");
                    listView.Dock = DockStyle.Fill;
                    listView.AllowUserToAddRows = false;
                    listView.AllowUserToDeleteRows = false;
                    listView.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells;
                    listView.RowHeadersVisible = false;
                    form.Controls.Add(listView);

                    foreach (string conflictedPackedFilepath in packFileConflictMap[item.Tag as PackFile])
                    {
                        List<string> conflictingPackFiles = new List<string>();
                        foreach (PackFile packFile in packedFileMap[conflictedPackedFilepath])
                            if (!ReferenceEquals(packFile, item.Tag))
                                conflictingPackFiles.Add(Path.GetFileNameWithoutExtension(packFile.Filepath));
                        listView.Rows.Add(new string[] { conflictedPackedFilepath, String.Join(", ", conflictingPackFiles.ToArray()) });
                    }

                    form.Show();
                }
            }
        }

        private void timerMM_Tick(object sender, EventArgs e)
        {
            this.Height = this.Height + mmChange;
            this.Top = this.Top - (mmChange / 2);

            if (mmChange == 10)
                mm++;
            else
                mm--;

            if (mm == 30)
            {
                timerMM.Enabled = false;
                buttonMM.Enabled = true;
                buttonMM.Text = "Hide Mod Manager";
                mmChange = -10;
            }
            else if (mm == 0)
            {
                timerMM.Enabled = false;
                buttonMM.Enabled = true;
                buttonMM.Text = "Show Mod Manager";
                mmChange = 10;
            }
        }

        private void buttonMM_Click(object sender, EventArgs e)
        {
            timerMM.Enabled = true;
            buttonMM.Enabled = false;
            mmShown = true;
        }

        private void buttonAbout_Click(object sender, EventArgs e)
        {
            MessageBox.Show("W.A.L.I  v" + Application.ProductVersion
                + "\nCopyright © Mitchell Heastie 2012\n\n"
                + "LUA Scripting\nDaniel Rogers\n\n"
                + "Mod Manager  v1.5\nCopyright © Matt Chambers\n\n"
                + "More info:\nhttps://sourceforge.net/projects/wali-engine/",
                "About", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        /// <summary>
        /// Launches the WALI engine
        /// </summary>
        /// <returns>Blank string if successful launch, else string containing error info</returns>
        public string LaunchWALI()
        {
            string waliPath = etwDataPath + "\\WALI\\Engine\\WALI_Engine.exe";

            //Ensure steam is running before allowing the game to start. Prevents bug where engine would
            //search for Empire process when steam was still starting up.
            Process[] pname = Process.GetProcessesByName("steam");
            if (pname.Length == 0)
                return "Steam is not running, please ensure Steam is running before trying to play using WALI";

            if (File.Exists(waliPath))
            {
                try
                {
                    Process proc = new Process();
                    proc.StartInfo.FileName = waliPath;
                    proc.StartInfo.Arguments = "Empire";
                    proc.Start();
                    return "";
                }
                catch (Exception e)
                {
                    ErrorLog(e.Message);
                    return "Failed to start";
                }
            }
            else
            {
                ErrorLog("Invalid path:" + waliPath);
                return "Invalid path (File not found): " + waliPath;
            }
        }


        public void ErrorLog(string message)
        {
            StreamWriter sw = null;
            try
            {
                string sLogFormat = DateTime.Now.ToString() + " ==> ";

                sw = new StreamWriter(etwDataPath + "\\WALI\\Engine\\Error_Log.txt", true);

                if (firstError == true)
                {
                    sw.WriteLine("**** LAUNCHER START ****\n\r\n\r" + Path.GetFileName(Application.ExecutablePath) + ":-" + sLogFormat + message);
                    firstError = false;
                }
                else
                {
                    sw.WriteLine(Path.GetFileName(Application.ExecutablePath) + ":-" + sLogFormat + message);
                }

                sw.Flush();
            }
            catch (Exception)
            {
                // Problem error logging
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
    }
}
