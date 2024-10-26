@echo off
setlocal enabledelayedexpansion

REM Version 30 (Correct 24-hour format in Data.txt and fix for unnamed exports)

:menu
REM Reset all variables at the start of the menu to clear any cached values from previous runs
set hexValue=
set regName=
set regKeyType=
set formattedHex=

REM Display the start menu for selecting a registry key or exporting one to a .reg file
echo --- Script Execution Started ---
echo Select an option:
echo [1] Query and save AsobimoOptionKey_Guest_h3614151626
echo [2] Query and save AsobimoOptionKey_h1824440549
echo [3] Query and save SteamOptionKey_h3876606495
echo [4] Export a registry key from Data.txt to a .reg file
echo [5] Exit
set /p keyChoice="Enter your choice (1-5): "

if "%keyChoice%"=="1" (
    set keyName=AsobimoOptionKey_Guest_h3614151626
    goto process
) else if "%keyChoice%"=="2" (
    set keyName=AsobimoOptionKey_h1824440549
    goto process
) else if "%keyChoice%"=="3" (
    set keyName=SteamOptionKey_h3876606495
    goto process
) else if "%keyChoice%"=="4" (
    goto exportFromData
) else if "%keyChoice%"=="5" (
    echo Exiting...
    exit /b
) else (
    echo Invalid choice. Please try again.
    goto menu
)

:process
REM Get current date and time for unnamed saves (24-hour format conversion)
for /f "tokens=1-4 delims=/- " %%A in ('date /t') do set shortDate=%%C-%%A-%%B

REM Use 24-hour format for time instead of 12-hour format
for /f "tokens=1-2 delims=: " %%A in ('time /t') do set shortTime=%%A-%%B

if "%time:~5,2%"=="PM" (
    if "%shortTime:~0,2%" NEQ "12" (
        set /a hour=%%A + 12
        set shortTime=%hour%-%B
    )
) else if "%time:~5,2%"=="AM" (
    if "%shortTime:~0,2%"=="12" (
        set shortTime=00-%B
    )
)

set shortDate=%shortDate:~2%

REM Ask user for custom save name or use default
set defaultName=%shortDate%_%shortTime%
set /p saveName="Enter a custom name for this key (or press Enter for default): "
if "%saveName%"=="" set saveName=%defaultName%

REM Query the registry key and capture the hex value
for /F "skip=2 tokens=2,*" %%A in ('reg query "HKEY_CURRENT_USER\SOFTWARE\Asobimo,Inc\ToramOnline" /v "%keyName%" 2^>nul') do (
    set "hexValue=%%B"
)

REM If no hexValue, show an error
if not defined hexValue (
    echo Registry key "%keyName%" not found or has no value.
    pause
    goto menu
)

REM Save the key data in Data.txt as key-value pairs
if not exist Data.txt (
    echo Name=,Type=,Hex= > Data.txt
)
if "%keyName%"=="AsobimoOptionKey_Guest_h3614151626" (
    echo Name=%saveName%,Type=Guest,Hex=%hexValue%>>Data.txt
) else (
    echo Name=%saveName%,Type=Key,Hex=%hexValue%>>Data.txt
)

echo Key saved successfully.
goto menu

:exportFromData
REM Reset variables before parsing
set regName=
set regKeyType=
set hexValue=

REM Check if Data.txt exists before trying to read it
if not exist Data.txt (
    echo Data.txt not found. Returning to menu.
    pause
    goto menu
)

REM Display available entries from Data.txt
echo --- Available Entries in Data.txt ---
set count=0

REM Parse key-value pairs from Data.txt
for /f "skip=1 tokens=1-3 delims=," %%A in (Data.txt) do (
    set /a count+=1

    REM Extract the Name, Type, and Hex values
    for /f "tokens=2 delims==" %%N in ("%%A") do set regName=%%N
    for /f "tokens=2 delims==" %%T in ("%%B") do set regKeyType=%%T
    for /f "tokens=2 delims==" %%H in ("%%C") do set hexValue=%%H

    echo [!count!] Name=!regName! Type=!regKeyType!
)

REM Ask for the key number to export
set /p entryNum="Enter the number of the entry you wish to export: "

REM Validate entry number
if %entryNum% GTR %count% (
    echo Invalid entry number.
    pause
    goto menu
)

REM Read the selected entry again
set lineCount=0
for /f "skip=1 tokens=1-3 delims=," %%A in (Data.txt) do (
    set /a lineCount+=1
    if "%lineCount%"=="%entryNum%" (
        REM Extract the Name, Type, and Hex values
        for /f "tokens=2 delims==" %%N in ("%%A") do set regName=%%N
        for /f "tokens=2 delims==" %%B in ("%%B") do set regKeyType=%%B
        for /f "tokens=2 delims==" %%C in ("%%C") do set hexValue=%%C
    )
)

REM Check if regName, regKeyType, and hexValue were read correctly
if not defined regName (
    echo ERROR: regName is empty. Please check Data.txt format.
    pause
    goto menu
)
if not defined hexValue (
    echo ERROR: hexValue is empty. Please check Data.txt format.
    pause
    goto menu
)

REM Debugging output for validation
echo Parsed registry key name: !regName!
echo Parsed registry key type: !regKeyType!
echo Parsed hex value: !hexValue!

REM Replace any invalid characters in the filename (like colon)
set regName=%regName::=-%

REM Set the key name based on the type
if /i "%regKeyType%"=="Guest" (
    set regKeyName=AsobimoOptionKey_Guest_h3614151626
) else if /i "%regKeyType%"=="Key" (
    set regKeyName=%regName%
) else (
    echo ERROR: Unrecognized key type. Please check Data.txt.
    pause
    goto menu
)

REM If no name is given, use regName as the default name for the .reg file
set /p regFileName="Enter the name for the .reg file (or press Enter for default): "
if "%regFileName%"=="" set regFileName=%regName%

REM Add .reg extension if it's not provided
if not "%regFileName:~-4%"==".reg" (
    set regFileName=%regFileName%.reg
)

REM Format hexValue into comma-separated byte pairs
set "formattedHex="
for /l %%i in (0,2,1000) do (
    if "!hexValue:~%%i,2!"=="" goto formatDone
    if defined formattedHex (
        set "formattedHex=!formattedHex!,!hexValue:~%%i,2!"
    ) else (
        set "formattedHex=!hexValue:~%%i,2!"
    )
)
:formatDone

REM Remove trailing comma
if "!formattedHex:~-1!"=="," set "formattedHex=!formattedHex:~0,-1!"

REM Write to .reg file with correct format
echo Writing to %regFileName%
(
    echo Windows Registry Editor Version 5.00
    echo.
    echo [HKEY_CURRENT_USER\SOFTWARE\Asobimo,Inc\ToramOnline]
    echo ^"!regKeyName!^"=hex:!formattedHex!
) > "%regFileName%"

REM Verify if the file was created and is non-empty
if exist "%regFileName%" (
    for %%A in ("%regFileName%") do if %%~zA GTR 0 (
        echo Registry key successfully exported to %regFileName%
    ) else (
        echo ERROR: File is empty. Please check the export process.
    )
) else (
    echo Failed to export the registry key.
)

pause
goto menu
