param (
    [string]$operation
)

Write-Host "Starting script with operation: $operation"

switch ($operation) {
    'query' {
        Write-Host "Executing query operation..."
        if (Test-Path -Path ".\QueryRegistry.ps1") {
            Write-Host "QueryRegistry.ps1 found. Running..."
            . .\QueryRegistry.ps1
        } else {
            Write-Host "QueryRegistry.ps1 not found."
        }
    }
    'export' {
        Write-Host "Executing export operation..."
        if (Test-Path -Path ".\ExportRegistry.ps1") {
            Write-Host "ExportRegistry.ps1 found. Running..."
            . .\ExportRegistry.ps1
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
    'exit' {
        Write-Host "Exiting script."
    }
    default {
        Write-Host "Invalid operation. Please choose 'query', 'export', 'view', or 'exit'."
    }
}

# Pause to keep the script window open
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null