namespace WALI_Engine
{
    partial class FormWALI
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormWALI));
            this.labelStats = new System.Windows.Forms.Label();
            this.buttonStop = new System.Windows.Forms.Button();
            this.timerStats = new System.Windows.Forms.Timer(this.components);
            this.SuspendLayout();
            // 
            // labelStats
            // 
            this.labelStats.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.labelStats.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.labelStats.Location = new System.Drawing.Point(12, 9);
            this.labelStats.Name = "labelStats";
            this.labelStats.Size = new System.Drawing.Size(246, 116);
            this.labelStats.TabIndex = 0;
            this.labelStats.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // buttonStop
            // 
            this.buttonStop.Location = new System.Drawing.Point(224, 99);
            this.buttonStop.Name = "buttonStop";
            this.buttonStop.Size = new System.Drawing.Size(45, 33);
            this.buttonStop.TabIndex = 1;
            this.buttonStop.Text = "STOP";
            this.buttonStop.UseVisualStyleBackColor = true;
            this.buttonStop.Visible = false;
            this.buttonStop.Click += new System.EventHandler(this.buttonStop_Click);
            // 
            // timerStats
            // 
            this.timerStats.Interval = 1000;
            this.timerStats.Tick += new System.EventHandler(this.timerStats_Tick);
            // 
            // FormWALI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(270, 134);
            this.Controls.Add(this.buttonStop);
            this.Controls.Add(this.labelStats);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FormWALI";
            this.Text = "Engine";
            this.Load += new System.EventHandler(this.FormWALI_Load);
            this.Shown += new System.EventHandler(this.FormWALI_Shown);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label labelStats;
        private System.Windows.Forms.Button buttonStop;
        private System.Windows.Forms.Timer timerStats;

    }
}

