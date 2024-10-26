using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace RegistryApp
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            LoadData();
        }

        private void LoadData()
        {
            if (File.Exists("Data.txt"))
            {
                var data = File.ReadAllLines("Data.txt")
                               .Select(line => line.Split(','))
                               .Select(parts => new RegistryEntry
                               {
                                   Name = parts[0].Split('=')[1],
                                   Type = parts[1].Split('=')[1]
                               }).ToList();
                DataGridRegistry.ItemsSource = data;
            }
        }

        private void BtnQuery1_Click(object sender, RoutedEventArgs e)
        {
            ExecutePowerShellScript("QueryRegistry.ps1", "AsobimoOptionKey_Guest_h3614151626");
            LoadData();
        }

        private void BtnQuery2_Click(object sender, RoutedEventArgs e)
        {
            ExecutePowerShellScript("QueryRegistry.ps1", "AsobimoOptionKey_h1824440549");
            LoadData();
        }

        private void BtnQuery3_Click(object sender, RoutedEventArgs e)
        {
            ExecutePowerShellScript("QueryRegistry.ps1", "SteamOptionKey_h3876606495");
            LoadData();
        }

        private void BtnExport_Click(object sender, RoutedEventArgs e)
        {
            var selectedEntry = DataGridRegistry.SelectedItem as RegistryEntry;
            if (selectedEntry != null)
            {
                string arguments = $"-File ExportRegistry.ps1 -EntryName {selectedEntry.Name} -EntryType {selectedEntry.Type}";
                ExecutePowerShellScript("ExportRegistry.ps1", arguments);
            }
        }

        private void ExecutePowerShellScript(string scriptPath, string argument)
        {
            string arguments = $"-NoExit -File {scriptPath} -ArgumentList {argument}";
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = arguments,
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            System.Diagnostics.Process process = System.Diagnostics.Process.Start(psi);
            process.WaitForExit();
        }
    }

    public class RegistryEntry
    {
        public string Name { get; set; }
        public string Type { get; set; }
    }
}