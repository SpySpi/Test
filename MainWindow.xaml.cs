using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Windows;

namespace RegistryApp
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            LoadRegistryData();
        }

        private void Button1_Click(object sender, RoutedEventArgs e)
        {
            RunScript("AsobimoOptionKey_Guest_h3614151626");
        }

        private void Button2_Click(object sender, RoutedEventArgs e)
        {
            RunScript("AsobimoOptionKey_h1824440549");
        }

        private void Button3_Click(object sender, RoutedEventArgs e)
        {
            RunScript("SteamOptionKey_h3876606495");
        }

        private void BtnExport_Click(object sender, RoutedEventArgs e)
        {
            if (DataGridRegistry.SelectedItem is RegistryItem selectedItem)
            {
                File.AppendAllText("ExportedData.txt", $"{selectedItem.Name},{selectedItem.Type}\n");
                MessageBox.Show("Selected item exported.");
            }
        }

        private void LoadRegistryData()
        {
            var registryItems = new List<RegistryItem>();

            if (File.Exists("Data.txt"))
            {
                var lines = File.ReadAllLines("Data.txt");
                foreach (var line in lines)
                {
                    var parts = line.Split(',');
                    if (parts.Length >= 3)
                    {
                        registryItems.Add(new RegistryItem
                        {
                            Name = parts[0].Split('=')[1],
                            Type = parts[1].Split('=')[1]
                        });
                    }
                }
            }

            DataGridRegistry.ItemsSource = registryItems;
        }

        private void RunScript(string key)
        {
            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = $"-File QueryRegistry.ps1 -key {key}",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
            };

            using (Process process = Process.Start(startInfo))
            {
                using (StreamReader reader = process.StandardOutput)
                {
                    string result = reader.ReadToEnd();
                    MessageBox.Show(result);
                }
            }
        }
    }

    public class RegistryItem
    {
        public string Name { get; set; }
        public string Type { get; set; }
    }
}