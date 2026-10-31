@echo off
setlocal EnableDelayedExpansion
title Monster Hunter Wilds Save Backup Script By APHONIC

rem Monster Hunter Wilds - Save Backup (Windows)
rem By APHONIC
rem
rem Copies your Monster Hunter Wilds Steam Cloud save into a timestamped folder,
rem then launches the game. It finds your Steam install, your account and the
rem save folder on its own.
rem
rem Edit BACKUP_DIR below to choose where backups go. Everything else auto-detects.
rem Set STEAM_USER_ID only to force a specific Steam account.
rem
rem Two ways to run it:
rem   1. Steam launch options (backs up every time you press Play, then starts the game):
rem        "C:\full\path\MH-WILDS_save_backup.bat" %%command%%
rem   2. Manually: double-click this file.

if not defined BACKUP_DIR set "BACKUP_DIR=%USERPROFILE%\MH-WILDS-Backups"
rem set "BACKUP_DIR=D:\Your\Backup\Location"

if not defined GAME_ID set "GAME_ID=2246340"
if not defined GAME_NAME set "GAME_NAME=Monster Hunter Wilds"
if not defined GAME_EXE set "GAME_EXE=MonsterHunterWilds.exe"
if not defined STEAM_USER_ID set "STEAM_USER_ID="
if not defined LAUNCH_GAME set "LAUNCH_GAME=1"

echo %GAME_NAME% - save backup
echo ==============================

set "STEAM="
for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul ^| findstr /i "SteamPath"') do set "STEAM=%%B"
if defined STEAM set "STEAM=%STEAM:/=\%"
if not defined STEAM if exist "%ProgramFiles(x86)%\Steam\userdata" set "STEAM=%ProgramFiles(x86)%\Steam"
if not defined STEAM (
    echo.
    echo [!] Could not find your Steam folder.
    goto :done_fail
)

set "SRC="
if defined STEAM_USER_ID (
    if exist "%STEAM%\userdata\%STEAM_USER_ID%\%GAME_ID%\remote\*" set "SRC=%STEAM%\userdata\%STEAM_USER_ID%\%GAME_ID%\remote"
) else (
    for /f "delims=" %%U in ('dir /b /ad /o-d "%STEAM%\userdata" 2^>nul') do (
        if not defined SRC if exist "%STEAM%\userdata\%%U\%GAME_ID%\remote\*" set "SRC=%STEAM%\userdata\%%U\%GAME_ID%\remote"
    )
)
if not defined SRC (
    echo.
    echo [!] No save found for app %GAME_ID%.
    echo     Make sure the game is installed and has saved at least once (Steam Cloud synced).
    echo     If the save is under another Steam account, set STEAM_USER_ID at the top.
    goto :done_fail
)

for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "TS=%%T"
set "DEST=%BACKUP_DIR%\%TS%"

echo.
echo Save folder:
echo   %SRC%
echo.
echo Backing up...
robocopy "%SRC%" "%DEST%" /E /NFL /NDL /NJH /NJS /NC /NS >nul
if errorlevel 8 (
    echo [!] Copy failed, nothing was backed up.
    goto :done_fail
)
echo Backup saved here:
echo   %DEST%

rem Steam launch-option mode: Steam passed the game command as arguments.
if not "%~1"=="" (
    %*
    exit /b
)

if "%LAUNCH_GAME%"=="1" (
    tasklist /fi "imagename eq %GAME_EXE%" 2>nul | find /i "%GAME_EXE%" >nul
    if errorlevel 1 (
        echo.
        echo Launching %GAME_NAME%...
        start "" "steam://rungameid/%GAME_ID%"
    ) else (
        echo.
        echo Game is already running, not launching it again.
    )
)

echo.
echo Done.
timeout /t 10 >nul
exit /b 0

:done_fail
echo.
timeout /t 20 >nul
exit /b 1
