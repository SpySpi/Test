function Export-RegistryKeys {
    # Export a single key from Data.txt to a .reg file

    # Read all lines from Data.txt
    if (Test-Path -Path "Data.txt") {
        $dataLines = Get-Content -Path "Data.txt"
        if ($dataLines.Count -eq 0) {
            Write-Host "Data.txt is empty. Nothing to export."
            return
        }

        # Display the entries and allow user to select one to export
        Write-Host "Available entries in Data.txt:"
        for ($i = 0; $i -lt $dataLines.Count; $i++) {
            $entry = $dataLines[$i] -split ","
            $name = ($entry[0] -split "=")[1]
            $type = ($entry[1] -split "=")[1]
            Write-Host "[$($i + 1)] Name=$name, Type=$type"
        }
        
        $selectedIndex = Read-Host "Enter the index of the entry to export:"
        $selectedIndex = $selectedIndex.Trim() - 1  # Adjust for 1-based indexing

        if ($selectedIndex -lt 0 -or $selectedIndex -ge $dataLines.Count) {
            Write-Host "Invalid index. Exiting script."
            return
        }

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
            # Ask user for key type (1 for Asobimo, 2 for Steam)
            $keyTypeChoice = Read-Host "Enter the key type (1 for Asobimo, 2 for Steam):"
            $keyName = if ($keyTypeChoice -eq "1") { "AsobimoOptionKey_h1824440549" } else { "SteamOptionKey_h3876606495" }
        }

        # Use the name from the selected entry as the default name
        $defaultName = ($dataLines[$selectedIndex] -split ",")[0] -split "="
        $defaultName = $defaultName[1]
        $regFileName = "$defaultName.reg"

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
    else {
        Write-Host "Data.txt not found. Please query and save some keys first."
    }
}

# Initiate script execution immediately
Export-RegistryKeys