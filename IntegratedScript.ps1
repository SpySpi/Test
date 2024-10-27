# Integrated script to handle GUI interactions with Data.txt, QueryRegistry.ps1, and ExportRegistry.ps1

function Main-GUIFunction {
    param (
        [string]$operation
    )

    Write-Host "Starting Main-GUIFunction with operation: $operation"

    try {
        switch ($operation) {
            'query' {
                Write-Host "Executing query operation..."
                if (Test-Path -Path ".\QueryRegistry.ps1") {
                    Write-Host "QueryRegistry.ps1 found. Running..."
                    . .\QueryRegistry.ps1
                    Query-RegistryKey
                } else {
                    Write-Host "QueryRegistry.ps1 not found."
                }
            }
            'export' {
                Write-Host "Executing export operation..."
                if (Test-Path -Path ".\ExportRegistry.ps1") {
                    Write-Host "ExportRegistry.ps1 found. Running..."
                    . .\ExportRegistry.ps1
                    Export-RegistryKeys
                } else {
                    Write-Host "ExportRegistry.ps1 not found."
                }
            }
            'view' {
                Write-Host "Executing view operation..."
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
                } else {
                    Write-Host "Data.txt not found."
                }
            }
            default {
                Write-Host "Invalid operation. Please choose 'query', 'export', or 'view'."
            }
        }
    } catch {
        Write-Host "An error occurred: $_"
    }

    # Pause to keep the script window open
    Write-Host "Press any key to exit..."
    [System.Console]::ReadKey() | Out-Null
}

# Example usage:
# Main-GUIFunction -operation 'query'
# Main-GUIFunction -operation 'export'
# Main-GUIFunction -operation 'view'