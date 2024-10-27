@echo off
echo Running IntegratedScript.ps1...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0IntegratedScript.ps1" -operation "select"
pause