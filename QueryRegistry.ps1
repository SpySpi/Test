param (
    [string]$key
)

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
    $regQueryResult = reg query "HKEY_CURRENT_USER\SOFTWARE\Asobimo,Inc\ToramOnline" /v "$key"

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

Query-RegistryKey -key $key