# Prompt the user for their choice
Write-Host "--- Query Script Execution Started ---"
Write-Host "Select an option:"
Write-Host "[1] Query and save AsobimoOptionKey_Guest_h3614151626 to Data.txt"
Write-Host "[2] Query and save AsobimoOptionKey_h1824440549 to Data.txt"
Write-Host "[3] Query and save SteamOptionKey_h3876606495 to Data.txt"
Write-Host "[4] Exit"
$choice = Read-Host "Enter your choice (1-4):"

switch ($choice) {
    '1' {
        Write-Host "Querying and saving AsobimoOptionKey_Guest_h3614151626 to Data.txt..."
        # Add your query logic here
    }
    '2' {
        Write-Host "Querying and saving AsobimoOptionKey_h1824440549 to Data.txt..."
        # Add your query logic here
    }
    '3' {
        Write-Host "Querying and saving SteamOptionKey_h3876606495 to Data.txt..."
        # Add your query logic here
    }
    '4' {
        Write-Host "Exiting script."
        return  # Exit the script immediately
    }
    default {
        Write-Host "Invalid choice. Exiting script."
        return  # Exit the script immediately
    }
}

# If any other operations are needed outside the switch
Write-Host "Querying registry for ..."
# Your registry querying logic here

Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null