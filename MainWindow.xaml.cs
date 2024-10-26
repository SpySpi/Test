using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace RegistryApp
{
    public partial class MainWindow : Window
    {
        private RegistryEntry _draggedItem;

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
            System.Diagnostics.Process.Start("powershell.exe", "-File QueryRegistry.ps1");
            LoadData();
        }

        private void BtnExport_Click(object sender, RoutedEventArgs e)
        {
            var selectedEntry = DataGridRegistry.SelectedItem as RegistryEntry;
            if (selectedEntry != null)
            {
                System.Diagnostics.Process.Start("powershell.exe", $" -File ExportRegistry.ps1 -EntryName {selectedEntry.Name} -EntryType {selectedEntry.Type}");
            }
        }

        private void BtnSave_Click(object sender, RoutedEventArgs e)
        {
            var data = DataGridRegistry.ItemsSource as List<RegistryEntry>;
            if (data != null)
            {
                File.WriteAllLines("Data.txt", data.Select(entry => $"Name={entry.Name},Type={entry.Type}"));
                MessageBox.Show("Changes saved successfully.");
            }
        }

        private void DataGridRegistry_PreviewMouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            var dataGrid = sender as DataGrid;
            var row = FindVisualParent<DataGridRow>(e.OriginalSource as DependencyObject);
            if (row == null) return;

            _draggedItem = row.Item as RegistryEntry;
            if (_draggedItem != null)
            {
                DragDrop.DoDragDrop(row, _draggedItem, DragDropEffects.Move);
            }
        }

        private void DataGridRegistry_DragEnter(object sender, DragEventArgs e)
        {
            e.Effects = DragDropEffects.Move;
        }

        private void DataGridRegistry_Drop(object sender, DragEventArgs e)
        {
            if (_draggedItem == null) return;

            var dataGrid = sender as DataGrid;
            var targetItem = FindVisualParent<DataGridRow>(e.OriginalSource as DependencyObject)?.Item as RegistryEntry;
            if (targetItem != null && !ReferenceEquals(_draggedItem, targetItem))
            {
                var data = dataGrid.ItemsSource as List<RegistryEntry>;
                if (data != null)
                {
                    var draggedIndex = data.IndexOf(_draggedItem);
                    var targetIndex = data.IndexOf(targetItem);

                    if (draggedIndex >= 0 && targetIndex >= 0)
                    {
                        data.RemoveAt(draggedIndex);
                        data.Insert(targetIndex, _draggedItem);
                    }
                }
            }
        }

        private static T FindVisualParent<T>(DependencyObject child) where T : DependencyObject
        {
            var parentObject = VisualTreeHelper.GetParent(child);
            if (parentObject == null) return null;

            var parent = parentObject as T;
            return parent ?? FindVisualParent<T>(parentObject);
        }
    }

    public class RegistryEntry
    {
        public string Name { get; set; }
        public string Type { get; set; }
    }
}