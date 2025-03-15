@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

:: Set date and time for the output file name
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm"') do set date_time=%%a

echo Select the game you want to capture
:: Browse files and Choose Game Executable
for /f "delims=" %%i in ('powershell -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.ShowDialog(); if ($dialog.FileName) { $dialog.FileName }"') do set "filename=%%~nxi"

cls
set /p "dtime=Enter Capture Delay (sec): "
set /p "ctime=Enter Capture Time (sec): "
echo Selected Game: %filename%
echo %dtime% seconds - Capture Delay
echo %ctime% seconds - Capture Time
timeout /t 3 /nobreak >nul
cls

:: Creates Capture folder if doesnt exist
if not exist "Captures" (
    mkdir "Captures"
)
set "output=Captures\%date_time%\%date_time%.csv"
mkdir "Captures\%date_time%"

:: Start capture
echo Starting capture...
powershell -c "[console]::beep(500, 350)"
"bin\PresentMon.exe" -process_name "%filename%" -output_file %output% -delay %dtime% -timed %ctime% -terminate_after_timed

cls
powershell -c "[console]::beep(500, 350)"
echo Capture finished.
timeout /t 3 /nobreak >nul
cls

set "ps_script=analyze.ps1"
if exist "%ps_script%" (
    echo [-] Running Powershell script for analysis...
    echo.
    powershell -exec bypass -f "%ps_script%" -csvFilePath "%output%" > nul
    echo Summary written to Captures\%date_time%\summary.txt
) else (
    echo Error: Powershell script not found
)
echo.

pause && exit /b
