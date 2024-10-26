# Version 13: Adding multiple key export functionality

# Define the registry keys to query
$keysToExport = @(
    "AsobimoOptionKey_Guest_h3614151626",
    "AsobimoOptionKey_h1824440549",
    "SteamOptionKey_h3876606495"
)

# Main menu loop
do {
    Clear-Host
    Write-Host "--- Script Execution Started ---"
    Write-Host "Select an option:"
    Write-Host "[1] Query and save AsobimoOptionKey_Guest_h3614151626 to Data.txt"
    Write-Host "[2] Query and save AsobimoOptionKey_h1824440549 to Data.txt"
    Write-Host "[3] Query and save SteamOptionKey_h3876606495 to Data.txt"
    Write-Host "[4] Export multiple keys from Data.txt to .reg"
    Write-Host "[5] Exit"

    $choice = Read-Host "Enter your choice (1-5):"

    if ($choice -eq '1' -or $choice -eq '2' -or $choice -eq '3') {
        # Get the selected key based on user choice
        $key = $keysToExport[$choice - 1]

        # Query the registry for the selected key
        Write-Host "Querying registry for ${key}..."
        $regQueryResult = reg query "HKEY_CURRENT_USER\SOFTWARE\Asobimo,Inc\ToramOnline" /v "$key"

        # Debugging: Output the raw registry query result to inspect the format
        Write-Host "Raw reg query result: `n$regQueryResult"

        # Split the query result on new lines and extract the relevant line (contains "REG_BINARY")
        $regQueryLines = $regQueryResult -split "`n"
        foreach ($line in $regQueryLines) {
            if ($line -match "$key\s+REG_BINARY\s+([0-9A-F]+)") {
                $hexValue = $matches[1]
                Write-Host "Hex Value for ${key}: $hexValue"

                # Prompt the user for a name
                $name = Read-Host "Enter a name for this key (or press Enter for default)"
                if ([string]::IsNullOrWhiteSpace($name)) {
                    $name = (Get-Date).ToString("yy-MM-dd_HH-mm")
                }

                # Save the key, type, and value to Data.txt
                $type = if ($key -like "*Guest*") { "Guest" } else { "Key" }
                Add-Content -Path "Data.txt" -Value "Name=$name,Type=$type,Value=$hexValue"
                Write-Host "Registry key saved to Data.txt"
                break
            }
        }
        if (-not $hexValue) {
            Write-Host "Failed to extract the registry value. Please verify the output above."
        }
    }
    elseif ($choice -eq '4') {
        # Export multiple keys from Data.txt to .reg file

        # Read all lines from Data.txt
        if (Test-Path -Path "Data.txt") {
            $dataLines = Get-Content -Path "Data.txt"
            if ($dataLines.Count -eq 0) {
                Write-Host "Data.txt is empty. Nothing to export."
            }
            else {
                # Ask the user to provide a name for the .reg file or use default
                $regFileName = Read-Host "Enter the name for the .reg file (or press Enter for default)"
                if ([string]::IsNullOrWhiteSpace($regFileName)) {
                    $regFileName = (Get-Date).ToString("yy-MM-dd_HH-mm") + ".reg"
                }
                else {
                    $regFileName = "$regFileName.reg"
                }

                # Write the header to the .reg file
                Set-Content -Path $regFileName -Value "Windows Registry Editor Version 5.00`r`n"
                Add-Content -Path $regFileName -Value "[HKEY_CURRENT_USER\SOFTWARE\Asobimo,Inc\ToramOnline]"

                # Loop through selected entries and add them to the .reg file
                foreach ($line in $dataLines) {
                    $entry = $line -split ","
                    $name = ($entry[0] -split "=")[1]
                    $type = ($entry[1] -split "=")[1]
                    $value = ($entry[2] -split "=")[1]

                    # Write each entry to the .reg file
                    Add-Content -Path $regFileName -Value "`r`n`"$name`"=hex:$value"
                }

                Write-Host "Registry keys successfully exported to $regFileName"
            }
        }
        else {
            Write-Host "Data.txt not found. Please query and save some keys first."
        }
    }

} while ($choice -ne '5')

Write-Host "Exiting script."
