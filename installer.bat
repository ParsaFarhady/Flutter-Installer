@echo off
:: Requesting admin rights if not already running as admin
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :continue
) else (
    echo Requesting administrative privileges...
    powershell start -verb runas '%0' 
    exit /b
)
:continue

:: Define variables
set "downloadURL=https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.5-stable.zip"
set "installPath=C:\flutter"
set "tempFolder=%TEMP%\FlutterInstaller"
set "zipFile=%tempFolder%\flutter.zip"

:: Create temporary folder
if not exist "%tempFolder%" mkdir "%tempFolder%"

:: Download Flutter zip file (tracking progress in MB)
echo Downloading Flutter...
bitsadmin /transfer "FlutterDownload" /download /priority foreground "%downloadURL%" "%zipFile%"

setlocal enabledelayedexpansion
set "totalBytes=0"
set "totalMB=0"

:loop
set "currentBytes=!totalBytes!"
bitsadmin /info "FlutterDownload" | findstr /C:"Bytes Received" > "%tempFolder%\progress.txt"
for /f "tokens=3" %%a in ('type "%tempFolder%\progress.txt"') do set "totalBytes=%%a"

set /a "deltaBytes=totalBytes-currentBytes"
set /a "totalMB+=deltaBytes/1048576"

cls
echo Downloading Flutter... %totalMB% MB
ping -n 2 127.0.0.1 >nul  :: Delay for 2 seconds

goto :loop

:end_loop
del "%tempFolder%\progress.txt"

:: Unzip Flutter
echo Extracting Flutter...
powershell -command "Expand-Archive -Path '%zipFile%' -DestinationPath '%installPath%' -Force"

:: Clean up temporary files
echo Cleaning up...
del /q "%zipFile%"
rmdir /q /s "%tempFolder%"

:: Add Flutter bin directory to PATH
setx /m PATH "%installPath%\bin;%PATH%"

:: Display completion message
echo.
echo Flutter has been successfully installed.
echo.
echo Please restart your command prompt to start using Flutter.
echo.
pause
