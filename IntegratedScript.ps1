# Integrated script to handle GUI interactions with Data.txt, QueryRegistry.ps1, and ExportRegistry.ps1

function Main-GUIFunction {
    param (
        [string]$operation
    )

    switch ($operation) {
        'query' {
            # Call Query-RegistryKey function from QueryRegistry.ps1
            . .\QueryRegistry.ps1
            Query-RegistryKey
        }
        'export' {
            # Call Export-RegistryKeys function from ExportRegistry.ps1
            . .\ExportRegistry.ps1
            Export-RegistryKeys
        }
        'view' {
            # Display contents of Data.txt
            if (Test-Path -Path "Data.txt") {
                $dataLines = Get-Content -Path "Data.txt"
                if ($dataLines.Count -eq 0) {
                    Write-Host "Data.txt is empty."
                } else {
                    Write-Host "Contents of Data.txt:"
                    foreach ($line in $dataLines) {
                        Write-Host $line
                    }
                }
            }
            else {
                Write-Host "Data.txt not found."
            }
        }
        default {
            Write-Host "Invalid operation. Please choose 'query', 'export', or 'view'."
        }
    }

    # Pause to keep the script window open
    Write-Host "Press any key to exit..."
    [System.Console]::ReadKey() | Out-Null
}

# Example usage:
# Main-GUIFunction -operation 'query'
# Main-GUIFunction -operation 'export'
# Main-GUIFunction -operation 'view'