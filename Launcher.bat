@echo off
setlocal enabledelayedexpansion

:: ====================================================
:: DNS Configuration Launcher
:: Author: EXLOUD
:: ====================================================

:: Define PowerShell paths
set "PS5_PATH=%systemdrive%\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
set "PS7_PATH=%ProgramFiles%\PowerShell\7\pwsh.exe"
set "PS7_PREVIEW_PATH=%ProgramFiles%\PowerShell\7-preview\pwsh.exe"

:: Find best PowerShell for admin elevation
set "ELEVATION_PS="
if exist "%PS7_PREVIEW_PATH%" (
    set "ELEVATION_PS=%PS7_PREVIEW_PATH%"
) else if exist "%PS7_PATH%" (
    set "ELEVATION_PS=%PS7_PATH%"
) else if exist "%PS5_PATH%" (
    set "ELEVATION_PS=%PS5_PATH%"
) else (
    echo [ERROR] No PowerShell found for elevation!
    pause
    exit /b 1
)

:: ====================================================
:: Launch with admin rights (REQUIRED for DNS changes)
:: ====================================================
if "%1"=="admin" goto :AdminMode

echo [INFO] DNS configuration requires administrator privileges...
echo [INFO] Requesting elevation...
"%ELEVATION_PS%" -Command "Start-Process cmd -ArgumentList '/c \"%~f0\" admin' -Verb RunAs"
exit /B

:AdminMode
pushd "%CD%"
CD /D "%~dp0"

:: ====================================================
:: Universal DNS Configuration Launcher
:: ====================================================

title Universal DNS Configuration Launcher

:: Set script directory
set "SCRIPT_DIR=%~dp0"

:: Initialize variables
set "PS_EXE="
set "PS_SCRIPT="
set "PS_VERSION="
set "SCRIPT_TYPE="

:: ====================================================
:: Find PowerShell Executable (priority: Preview > 7 > 5)
:: ====================================================

if exist "%PS7_PREVIEW_PATH%" (
    set "PS_EXE=%PS7_PREVIEW_PATH%"
    set "PS_VERSION=PowerShell 7 Preview"
    set "PS_MAJOR=7"
    goto :found_powershell
)

if exist "%PS7_PATH%" (
    set "PS_EXE=%PS7_PATH%"
    set "PS_VERSION=PowerShell 7"
    set "PS_MAJOR=7"
    goto :found_powershell
)

if exist "%PS5_PATH%" (
    set "PS_EXE=%PS5_PATH%"
    set "PS_VERSION=PowerShell 5"
    set "PS_MAJOR=5"
    goto :found_powershell
)

echo [ERROR] No compatible PowerShell version found!
echo.
echo Please install either:
echo  - PowerShell 7 Preview (recommended for best Unicode support)
echo  - PowerShell 7 
echo  - PowerShell 5 (Windows PowerShell)
echo.
pause
exit /b 1

:found_powershell

:: ====================================================
:: Detect Windows Version
:: ====================================================
for /f "tokens=4-5 delims=. " %%i in ('ver') do (
    set "WIN_MAJOR=%%i"
    set "WIN_MINOR=%%j"
)

:: For DNS configuration, we use the same script for all versions
:: as it uses standard PowerShell cmdlets
set "SCRIPT_BASENAME=dns_changer.ps1"
set "SCRIPT_TYPE=DNS Configuration Script"

:: ====================================================
:: Locate Script
:: ====================================================
set "SCRIPT_FOUND="

:: Check in current directory
set "TEST_SCRIPT=%SCRIPT_DIR%!SCRIPT_BASENAME!"
if exist "!TEST_SCRIPT!" (
    set "PS_SCRIPT=!TEST_SCRIPT!"
    set "SCRIPT_FOUND=YES"
    goto :script_found
)

:: Check in script subfolder
set "TEST_SCRIPT=%SCRIPT_DIR%script\!SCRIPT_BASENAME!"
if exist "!TEST_SCRIPT!" (
    set "PS_SCRIPT=!TEST_SCRIPT!"
    set "SCRIPT_FOUND=YES"
    set "SCRIPT_TYPE=!SCRIPT_TYPE! (from script folder)"
    goto :script_found
)

:: Check in dns subfolder
set "TEST_SCRIPT=%SCRIPT_DIR%dns\!SCRIPT_BASENAME!"
if exist "!TEST_SCRIPT!" (
    set "PS_SCRIPT=!TEST_SCRIPT!"
    set "SCRIPT_FOUND=YES"
    set "SCRIPT_TYPE=!SCRIPT_TYPE! (from dns folder)"
    goto :script_found
)

echo [ERROR] Expected script !SCRIPT_BASENAME! not found!
echo.
echo Please make sure this script exists:
echo  - !SCRIPT_BASENAME!
echo.
echo It should be in one of these locations:
echo  - Same folder as this launcher
echo  - 'script' subfolder
echo  - 'dns' subfolder
echo.
pause
exit /b 1

:script_found

cd /d "%SCRIPT_DIR%"

:: Launch the PowerShell script
"%PS_EXE%" -ExecutionPolicy Bypass -NoProfile -File "!PS_SCRIPT!"

exit /b