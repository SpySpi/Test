@echo off
echo --- Operation Selection ---
echo [1] Query
echo [2] Export
echo [3] View
echo [4] Exit
set /p choice="Select an operation (1-4): "

if "%choice%"=="1" set operation=query
if "%choice%"=="2" set operation=export
if "%choice%"=="3" set operation=view
if "%choice%"=="4" set operation=exit

if not defined operation (
    echo Invalid choice. Exiting.
    pause
    exit /b 1
)

echo Running IntegratedScript.ps1 with operation %operation%...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0IntegratedScript.ps1" -operation "%operation%"
pause