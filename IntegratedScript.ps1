# Define the registry keys to query
$keysToExport = @(
    "AsobimoOptionKey_Guest_h3614151626",
    "AsobimoOptionKey_h1824440549",
    "SteamOptionKey_h3876606495"
)

function Query-RegistryKey {
    param (
        [string]$key
    )

    # Query the registry for the selected key
    Write-Host "Querying registry for ${key}..."
    $regQueryResult = & reg query "HKEY_CURRENT_USER\SOFTWARE\Asobimo,Inc\ToramOnline" /v "$key"

    # Debugging: Output the raw registry query result to inspect the format
    Write-Host "Raw reg query result: `n$regQueryResult"

    # Split the query result on new lines and extract the relevant line (contains "REG_BINARY")
    $regQueryLines = $regQueryResult -split "`n"
    foreach ($line in $regQueryLines) {
        if ($line -match "$key\s+REG_BINARY\s+([0-9A-F]+)") {
            $hexValue = $matches[1]
            Write-Host "Hex Value for ${key}: $hexValue"

            # Use a default name based on the current date and time
            $name = (Get-Date).ToString("yy-MM-dd_HH-mm")

            # Save the key, type, and value to Data.txt
            $type = if ($key -like "*Guest*") { "Guest" } else { "Key" }
            Add-Content -Path "Data.txt" -Value "Name=$name,Type=$type,Value=$hexValue"
            Write-Host "Registry key saved to Data.txt"
            return
        }
    }
    Write-Host "Failed to extract the registry value. Please verify the output above."
}

function Export-RegistryKeys {
    # Export a single key from Data.txt to .reg file

    # Read all lines from Data.txt
    if (Test-Path -Path "Data.txt") {
        $dataLines = Get-Content -Path "Data.txt"
        if ($dataLines.Count -eq 0) {
            Write-Host "Data.txt is empty. Nothing to export."
        }
        else {
            # Display the entries and allow user to select one to export
            Write-Host "Available entries in Data.txt:"
            for ($i = 0; $i -lt $dataLines.Count; $i++) {
                $entry = $dataLines[$i] -split ","
                $name = ($entry[0] -split "=")[1]
                $type = ($entry[1] -split "=")[1]
                Write-Host "[$i] Name=$name, Type=$type"
            }
            $selectedIndex = Read-Host "Enter the index of the entry to export:"
            $selectedIndex = $selectedIndex.Trim()

            # Add the selected entry to the .reg file
            $line = $dataLines[$selectedIndex]
            $entry = $line -split ","
            $name = ($entry[0] -split "=")[1]
            $type = ($entry[1] -split "=")[1]
            $value = ($entry[2] -split "=")[1]

            # Determine the correct key name based on type
            if ($type -eq "Guest") {
                $keyName = "AsobimoOptionKey_Guest_h3614151626"
            }
            else {
                $keyName = "AsobimoOptionKey_h1824440549"
            }

            # Use the name from the selected entry as the .reg file name
            $regFileName = "$name.reg"

            # Write the header to the .reg file
            Set-Content -Path $regFileName -Value "Windows Registry Editor Version 5.00`r`n"
            Add-Content -Path $regFileName -Value "[HKEY_CURRENT_USER\SOFTWARE\Asobimo,Inc\ToramOnline]"

            # Format hex value into comma-separated byte pairs
            $hexBytes = $value -split '(?<=\G..)'
            $formattedHex = -join ($hexBytes -join ',')

            # Write the entry to the .reg file without trailing comma
            if ($formattedHex.EndsWith(",")) {
                $formattedHex = $formattedHex.TrimEnd(",")
            }
            Add-Content -Path $regFileName -Value "`r`n`"$keyName`"=hex:$formattedHex"

            Write-Host "Registry key successfully exported to $regFileName"
        }
    }
    else {
        Write-Host "Data.txt not found. Please query and save some keys first."
    }
}

function Main-GUIFunction {
    param (
        [string]$operation
    )

    switch ($operation) {
        'query' {
            # Call Query-RegistryKey function
            Write-Host "Available keys to query:"
            for ($i = 0; $i -lt $keysToExport.Count; $i++) {
                Write-Host "[$i] $keysToExport[$i]"
            }
            $selectedIndex = Read-Host "Enter the index of the key to query:"
            $selectedIndex = $selectedIndex.Trim()
            Query-RegistryKey -key $keysToExport[$selectedIndex]
        }
        'export' {
            # Call Export-RegistryKeys function
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
}

# Example usage:
# Main-GUIFunction -operation 'query'
# Main-GUIFunction -operation 'export'
# Main-GUIFunction -operation 'view'