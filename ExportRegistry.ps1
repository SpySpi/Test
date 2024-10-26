# ExportRegistry.ps1

function Export-RegistryKeys {
    # Export multiple keys from Data.txt to .reg file

    # Read all lines from Data.txt
    if (Test-Path -Path "Data.txt") {
        $dataLines = Get-Content -Path "Data.txt"
        if ($dataLines.Count -eq 0) {
            Write-Host "Data.txt is empty. Nothing to export."
        }
        else {
            # Display the entries and allow user to select which ones to export
            Write-Host "Available entries in Data.txt:"
            for ($i = 0; $i -lt $dataLines.Count; $i++) {
                Write-Host "[$i] $dataLines[$i]"
            }
            $selectedIndices = Read-Host "Enter the indices of the entries to export (comma-separated):"
            $selectedIndices = $selectedIndices -split "," | ForEach-Object { $_.Trim() }

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
            foreach ($index in $selectedIndices) {
                $line = $dataLines[$index]
                $entry = $line -split ","
                $name = ($entry[0] -split "=")[1]
                $type = ($entry[1] -split "=")[1]
                $value = ($entry[2] -split "=")[1]

                # Determine the correct key name based on type
                $keyName = if ($type -eq "Guest") { "AsobimoOptionKey_Guest_h3614151626" } else { "SteamOptionKey_h3876606495" }

                # Format hex value into comma-separated byte pairs
                $hexBytes = $value -split '(?<=\G..)'
                $formattedHex = -join ($hexBytes -join ',')

                # Write each entry to the .reg file
                Add-Content -Path $regFileName -Value "`r`n`"$keyName`"=hex:$formattedHex"
            }

            # Remove the trailing comma from the last entry
            (Get-Content -Path $regFileName) -replace ",$", "" | Set-Content -Path $regFileName

            Write-Host "Registry keys successfully exported to $regFileName"
        }
    }
    else {
        Write-Host "Data.txt not found. Please query and save some keys first."
    }
}

# Main menu loop
do {
    Clear-Host
    Write-Host "--- Export Script Execution Started ---"
    Write-Host "[1] Export multiple keys from Data.txt to .reg"
    Write-Host "[2] Exit"

    $choice = Read-Host "Enter your choice (1-2):"

    switch ($choice) {
        '1' { Export-RegistryKeys }
        '2' { Write-Host "Exiting script." }
        default { Write-Host "Invalid choice. Please try again." }
    }

} while ($choice -ne '2')