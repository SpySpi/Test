param (
    [string]$operation
)

function Show-Menu {
    Clear-Host
    Write-Host "--- Operation Selection ---"
    Write-Host "[1] Query"
    Write-Host "[2] Export"
    Write-Host "[3] View"
    Write-Host "[4] Exit"
}

function Execute-Operation {
    param (
        [string]$operation
    )

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
            exit
        }
        default {
            Write-Host "Invalid operation. Please choose 'query', 'export', 'view', or 'exit'."
        }
    }
}

if ($operation -eq "select") {
    while ($true) {
        Show-Menu
        $choice = Read-Host "Enter your choice (1-4)"
        
        switch ($choice) {
            '1' { Execute-Operation -operation 'query' }
            '2' { Execute-Operation -operation 'export' }
            '3' { Execute-Operation -operation 'view' }
            '4' { Execute-Operation -operation 'exit' }
            default { Write-Host "Invalid choice. Please enter a number between 1 and 4." }
        }

        Write-Host "Press any key to continue..."
        [System.Console]::ReadKey() | Out-Null
    }
} else {
    Execute-Operation -operation $operation
}