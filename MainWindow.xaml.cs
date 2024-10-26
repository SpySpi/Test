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

        private void BtnQuery_Click(object sender, RoutedEventArgs e)
        {
            // Execute QueryRegistry.ps1
            System.Diagnostics.Process.Start("powershell.exe", "-File QueryRegistry.ps1");
            LoadData(); // Reload data after querying
        }

        private void BtnExport_Click(object sender, RoutedEventArgs e)
        {
            var selectedEntry = DataGridRegistry.SelectedItem as RegistryEntry;
            if (selectedEntry != null)
            {
                // Execute ExportRegistry.ps1 with selected entry
                System.Diagnostics.Process.Start("powershell.exe", $"-File ExportRegistry.ps1 -EntryName {selectedEntry.Name} -EntryType {selectedEntry.Type}");
            }
        }
    }

    public class RegistryEntry
    {
        public string Name { get; set; }
        public string Type { get; set; }
    }
}