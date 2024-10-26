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
}