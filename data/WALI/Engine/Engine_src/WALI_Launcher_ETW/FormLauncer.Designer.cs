namespace WALI_Launcher_ETW
{
    partial class FormLauncer
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormLauncer));
            System.Windows.Forms.ListViewGroup listViewGroup1 = new System.Windows.Forms.ListViewGroup("Release Packs", System.Windows.Forms.HorizontalAlignment.Left);
            System.Windows.Forms.ListViewGroup listViewGroup2 = new System.Windows.Forms.ListViewGroup("Patch Packs", System.Windows.Forms.HorizontalAlignment.Left);
            System.Windows.Forms.ListViewGroup listViewGroup3 = new System.Windows.Forms.ListViewGroup("Mod Packs", System.Windows.Forms.HorizontalAlignment.Left);
            System.Windows.Forms.ListViewGroup listViewGroup4 = new System.Windows.Forms.ListViewGroup("Movie Packs", System.Windows.Forms.HorizontalAlignment.Left);
            this.launchGameButton = new System.Windows.Forms.Button();
            this.findETWPathFolderBrowserDialog = new System.Windows.Forms.FolderBrowserDialog();
            this.label1 = new System.Windows.Forms.Label();
            this.moveUpButton = new System.Windows.Forms.Button();
            this.moveDownButton = new System.Windows.Forms.Button();
            this.profilesComboBox = new System.Windows.Forms.ComboBox();
            this.lbl_profiles = new System.Windows.Forms.Label();
            this.saveProfileButton = new System.Windows.Forms.Button();
            this.nameColumn = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.authorsColumn = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.versionColumn = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.conflictColumn = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.modListView = new System.Windows.Forms.ListView();
            this.deleteProfileButton = new System.Windows.Forms.Button();
            this.showAllPackTypesCheckBox = new System.Windows.Forms.CheckBox();
            this.showVanillaConflictsCheckBox = new System.Windows.Forms.CheckBox();
            this.linkLabel1 = new System.Windows.Forms.LinkLabel();
            this.buttonAbout = new System.Windows.Forms.Button();
            this.groupBoxDesc = new System.Windows.Forms.GroupBox();
            this.labelInfo = new System.Windows.Forms.Label();
            this.buttonMM = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.timerMM = new System.Windows.Forms.Timer(this.components);
            this.backgroundWorker1 = new System.ComponentModel.BackgroundWorker();
            this.groupBoxDesc.SuspendLayout();
            this.SuspendLayout();
            // 
            // launchGameButton
            // 
            this.launchGameButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.launchGameButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.launchGameButton.Image = ((System.Drawing.Image)(resources.GetObject("launchGameButton.Image")));
            this.launchGameButton.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.launchGameButton.Location = new System.Drawing.Point(656, 26);
            this.launchGameButton.Name = "launchGameButton";
            this.launchGameButton.Padding = new System.Windows.Forms.Padding(6, 0, 0, 0);
            this.launchGameButton.Size = new System.Drawing.Size(112, 75);
            this.launchGameButton.TabIndex = 3;
            this.launchGameButton.Text = "Launch";
            this.launchGameButton.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.launchGameButton.UseVisualStyleBackColor = true;
            this.launchGameButton.Click += new System.EventHandler(this.launchGameButton_Click);
            // 
            // findETWPathFolderBrowserDialog
            // 
            this.findETWPathFolderBrowserDialog.Description = "Unable to automatically find the path to Empire.exe, please locate it manually.";
            this.findETWPathFolderBrowserDialog.RootFolder = System.Environment.SpecialFolder.MyComputer;
            this.findETWPathFolderBrowserDialog.ShowNewFolderButton = false;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(16, 208);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(436, 39);
            this.label1.TabIndex = 1;
            this.label1.Text = "The list is showing all pack files that are currently present in your ETW data di" +
    "rectory.\r\n\r\nUncheck \"Show all pack types\" to enable or disable mod packs or chan" +
    "ge their load order.";
            // 
            // moveUpButton
            // 
            this.moveUpButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.moveUpButton.Enabled = false;
            this.moveUpButton.Font = new System.Drawing.Font("Wingdings", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.moveUpButton.Location = new System.Drawing.Point(616, 298);
            this.moveUpButton.Name = "moveUpButton";
            this.moveUpButton.Size = new System.Drawing.Size(29, 27);
            this.moveUpButton.TabIndex = 4;
            this.moveUpButton.Text = "é";
            this.moveUpButton.UseCompatibleTextRendering = true;
            this.moveUpButton.UseVisualStyleBackColor = true;
            this.moveUpButton.Click += new System.EventHandler(this.moveUpButton_Click);
            // 
            // moveDownButton
            // 
            this.moveDownButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.moveDownButton.Enabled = false;
            this.moveDownButton.Font = new System.Drawing.Font("Wingdings", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.moveDownButton.Location = new System.Drawing.Point(616, 324);
            this.moveDownButton.Name = "moveDownButton";
            this.moveDownButton.Size = new System.Drawing.Size(29, 27);
            this.moveDownButton.TabIndex = 5;
            this.moveDownButton.Text = "ê";
            this.moveDownButton.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.moveDownButton.UseCompatibleTextRendering = true;
            this.moveDownButton.UseVisualStyleBackColor = true;
            this.moveDownButton.Click += new System.EventHandler(this.moveDownButton_Click);
            // 
            // profilesComboBox
            // 
            this.profilesComboBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.profilesComboBox.FormattingEnabled = true;
            this.profilesComboBox.Location = new System.Drawing.Point(616, 445);
            this.profilesComboBox.Name = "profilesComboBox";
            this.profilesComboBox.Size = new System.Drawing.Size(147, 21);
            this.profilesComboBox.TabIndex = 9;
            this.profilesComboBox.SelectedIndexChanged += new System.EventHandler(this.profilesComboBox_SelectedIndexChanged);
            this.profilesComboBox.TextChanged += new System.EventHandler(this.profilesComboBox_TextChanged);
            // 
            // lbl_profiles
            // 
            this.lbl_profiles.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbl_profiles.AutoSize = true;
            this.lbl_profiles.Font = new System.Drawing.Font("Verdana", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lbl_profiles.Location = new System.Drawing.Point(613, 429);
            this.lbl_profiles.Name = "lbl_profiles";
            this.lbl_profiles.Size = new System.Drawing.Size(87, 13);
            this.lbl_profiles.TabIndex = 10;
            this.lbl_profiles.Text = "Select Profile:";
            this.lbl_profiles.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // saveProfileButton
            // 
            this.saveProfileButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.saveProfileButton.Location = new System.Drawing.Point(616, 472);
            this.saveProfileButton.Name = "saveProfileButton";
            this.saveProfileButton.Size = new System.Drawing.Size(70, 23);
            this.saveProfileButton.TabIndex = 11;
            this.saveProfileButton.Text = "Save";
            this.saveProfileButton.UseVisualStyleBackColor = true;
            this.saveProfileButton.Click += new System.EventHandler(this.saveProfileButton_Click);
            // 
            // nameColumn
            // 
            this.nameColumn.Text = "Name";
            this.nameColumn.Width = 102;
            // 
            // authorsColumn
            // 
            this.authorsColumn.Text = "Authors";
            this.authorsColumn.Width = 126;
            // 
            // versionColumn
            // 
            this.versionColumn.Text = "Version";
            this.versionColumn.Width = 61;
            // 
            // conflictColumn
            // 
            this.conflictColumn.Text = "Conflicts";
            // 
            // modListView
            // 
            this.modListView.Activation = System.Windows.Forms.ItemActivation.OneClick;
            this.modListView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.modListView.CheckBoxes = true;
            this.modListView.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.nameColumn,
            this.authorsColumn,
            this.versionColumn,
            this.conflictColumn});
            this.modListView.DataBindings.Add(new System.Windows.Forms.Binding("ShowGroups", global::WALI_Launcher_ETW.Properties.Settings.Default, "ShowAllPackTypes", true, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged));
            this.modListView.FullRowSelect = true;
            listViewGroup1.Header = "Release Packs";
            listViewGroup1.Name = "releasePackGroup";
            listViewGroup2.Header = "Patch Packs";
            listViewGroup2.Name = "patchPackGroup";
            listViewGroup3.Header = "Mod Packs";
            listViewGroup3.Name = "modPackGroup";
            listViewGroup4.Header = "Movie Packs";
            listViewGroup4.Name = "moviePackGroup";
            this.modListView.Groups.AddRange(new System.Windows.Forms.ListViewGroup[] {
            listViewGroup1,
            listViewGroup2,
            listViewGroup3,
            listViewGroup4});
            this.modListView.HeaderStyle = System.Windows.Forms.ColumnHeaderStyle.Nonclickable;
            this.modListView.HideSelection = false;
            this.modListView.Location = new System.Drawing.Point(19, 285);
            this.modListView.MultiSelect = false;
            this.modListView.Name = "modListView";
            this.modListView.ShowGroups = global::WALI_Launcher_ETW.Properties.Settings.Default.ShowAllPackTypes;
            this.modListView.Size = new System.Drawing.Size(577, 210);
            this.modListView.TabIndex = 12;
            this.modListView.UseCompatibleStateImageBehavior = false;
            this.modListView.View = System.Windows.Forms.View.Details;
            this.modListView.SelectedIndexChanged += new System.EventHandler(this.modListView_SelectedIndexChanged);
            this.modListView.MouseClick += new System.Windows.Forms.MouseEventHandler(this.modListView_MouseClick);
            // 
            // deleteProfileButton
            // 
            this.deleteProfileButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.deleteProfileButton.Enabled = false;
            this.deleteProfileButton.Location = new System.Drawing.Point(693, 472);
            this.deleteProfileButton.Name = "deleteProfileButton";
            this.deleteProfileButton.Size = new System.Drawing.Size(70, 23);
            this.deleteProfileButton.TabIndex = 13;
            this.deleteProfileButton.Text = "Delete";
            this.deleteProfileButton.UseVisualStyleBackColor = true;
            this.deleteProfileButton.Click += new System.EventHandler(this.deleteProfileButton_Click);
            // 
            // showAllPackTypesCheckBox
            // 
            this.showAllPackTypesCheckBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.showAllPackTypesCheckBox.AutoSize = true;
            this.showAllPackTypesCheckBox.Checked = global::WALI_Launcher_ETW.Properties.Settings.Default.ShowAllPackTypes;
            this.showAllPackTypesCheckBox.DataBindings.Add(new System.Windows.Forms.Binding("Checked", global::WALI_Launcher_ETW.Properties.Settings.Default, "ShowAllPackTypes", true, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged));
            this.showAllPackTypesCheckBox.Location = new System.Drawing.Point(616, 370);
            this.showAllPackTypesCheckBox.Name = "showAllPackTypesCheckBox";
            this.showAllPackTypesCheckBox.Size = new System.Drawing.Size(121, 17);
            this.showAllPackTypesCheckBox.TabIndex = 14;
            this.showAllPackTypesCheckBox.Text = "Show all pack types";
            this.showAllPackTypesCheckBox.UseVisualStyleBackColor = true;
            this.showAllPackTypesCheckBox.Click += new System.EventHandler(this.showAllPackTypesButton_Click);
            // 
            // showVanillaConflictsCheckBox
            // 
            this.showVanillaConflictsCheckBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.showVanillaConflictsCheckBox.AutoSize = true;
            this.showVanillaConflictsCheckBox.Checked = global::WALI_Launcher_ETW.Properties.Settings.Default.ShowVanillaConflicts;
            this.showVanillaConflictsCheckBox.CheckState = System.Windows.Forms.CheckState.Checked;
            this.showVanillaConflictsCheckBox.DataBindings.Add(new System.Windows.Forms.Binding("Checked", global::WALI_Launcher_ETW.Properties.Settings.Default, "ShowVanillaConflicts", true, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged));
            this.showVanillaConflictsCheckBox.Location = new System.Drawing.Point(616, 393);
            this.showVanillaConflictsCheckBox.Name = "showVanillaConflictsCheckBox";
            this.showVanillaConflictsCheckBox.Size = new System.Drawing.Size(128, 17);
            this.showVanillaConflictsCheckBox.TabIndex = 16;
            this.showVanillaConflictsCheckBox.Text = "Show vanilla conflicts";
            this.showVanillaConflictsCheckBox.UseVisualStyleBackColor = true;
            this.showVanillaConflictsCheckBox.Click += new System.EventHandler(this.showVanillaConflictsCheckBox_Click);
            // 
            // linkLabel1
            // 
            this.linkLabel1.AutoSize = true;
            this.linkLabel1.Location = new System.Drawing.Point(16, 259);
            this.linkLabel1.Name = "linkLabel1";
            this.linkLabel1.Size = new System.Drawing.Size(95, 13);
            this.linkLabel1.TabIndex = 15;
            this.linkLabel1.TabStop = true;
            this.linkLabel1.Text = "What is a conflict?";
            // 
            // buttonAbout
            // 
            this.buttonAbout.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonAbout.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonAbout.Location = new System.Drawing.Point(656, 112);
            this.buttonAbout.Name = "buttonAbout";
            this.buttonAbout.Size = new System.Drawing.Size(112, 40);
            this.buttonAbout.TabIndex = 26;
            this.buttonAbout.Text = "About";
            this.buttonAbout.UseVisualStyleBackColor = true;
            this.buttonAbout.Click += new System.EventHandler(this.buttonAbout_Click);
            // 
            // groupBoxDesc
            // 
            this.groupBoxDesc.Controls.Add(this.labelInfo);
            this.groupBoxDesc.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBoxDesc.Location = new System.Drawing.Point(15, 9);
            this.groupBoxDesc.Name = "groupBoxDesc";
            this.groupBoxDesc.Size = new System.Drawing.Size(631, 151);
            this.groupBoxDesc.TabIndex = 25;
            this.groupBoxDesc.TabStop = false;
            this.groupBoxDesc.Text = "W.A.L.I";
            // 
            // labelInfo
            // 
            this.labelInfo.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelInfo.Location = new System.Drawing.Point(7, 23);
            this.labelInfo.Name = "labelInfo";
            this.labelInfo.Size = new System.Drawing.Size(617, 121);
            this.labelInfo.TabIndex = 0;
            this.labelInfo.Text = resources.GetString("labelInfo.Text");
            // 
            // buttonMM
            // 
            this.buttonMM.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonMM.Location = new System.Drawing.Point(13, 166);
            this.buttonMM.Name = "buttonMM";
            this.buttonMM.Size = new System.Drawing.Size(150, 31);
            this.buttonMM.TabIndex = 27;
            this.buttonMM.Text = "Show Mod Manager";
            this.buttonMM.UseVisualStyleBackColor = true;
            this.buttonMM.Click += new System.EventHandler(this.buttonMM_Click);
            // 
            // label2
            // 
            this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(631, 208);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(132, 50);
            this.label2.TabIndex = 33;
            this.label2.Text = "All credit for the Mod Manager source code goes to Matt Chambers.";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // timerMM
            // 
            this.timerMM.Interval = 10;
            this.timerMM.Tick += new System.EventHandler(this.timerMM_Tick);
            // 
            // FormLauncer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(776, 509);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.buttonMM);
            this.Controls.Add(this.buttonAbout);
            this.Controls.Add(this.groupBoxDesc);
            this.Controls.Add(this.showVanillaConflictsCheckBox);
            this.Controls.Add(this.linkLabel1);
            this.Controls.Add(this.showAllPackTypesCheckBox);
            this.Controls.Add(this.deleteProfileButton);
            this.Controls.Add(this.modListView);
            this.Controls.Add(this.saveProfileButton);
            this.Controls.Add(this.lbl_profiles);
            this.Controls.Add(this.profilesComboBox);
            this.Controls.Add(this.moveDownButton);
            this.Controls.Add(this.moveUpButton);
            this.Controls.Add(this.launchGameButton);
            this.Controls.Add(this.label1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MinimumSize = new System.Drawing.Size(615, 236);
            this.Name = "FormLauncer";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Mod Manager (Empire: Total War)";
            this.Load += new System.EventHandler(this.ModManagerForm_Load);
            this.Shown += new System.EventHandler(this.ModManagerForm_Shown);
            this.groupBoxDesc.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button launchGameButton;
        private System.Windows.Forms.FolderBrowserDialog findETWPathFolderBrowserDialog;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button moveUpButton;
        private System.Windows.Forms.Button moveDownButton;
        private System.Windows.Forms.ComboBox profilesComboBox;
        private System.Windows.Forms.Label lbl_profiles;
        private System.Windows.Forms.Button saveProfileButton;
        private System.Windows.Forms.ColumnHeader nameColumn;
        private System.Windows.Forms.ColumnHeader authorsColumn;
        private System.Windows.Forms.ColumnHeader versionColumn;
        private System.Windows.Forms.ColumnHeader conflictColumn;
        private System.Windows.Forms.ListView modListView;
        private System.Windows.Forms.Button deleteProfileButton;
        private System.Windows.Forms.CheckBox showAllPackTypesCheckBox;
        private System.Windows.Forms.CheckBox showVanillaConflictsCheckBox;
        private System.Windows.Forms.LinkLabel linkLabel1;
        private System.Windows.Forms.Button buttonAbout;
        private System.Windows.Forms.GroupBox groupBoxDesc;
        private System.Windows.Forms.Label labelInfo;
        private System.Windows.Forms.Button buttonMM;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Timer timerMM;
        private System.ComponentModel.BackgroundWorker backgroundWorker1;
    }
}

