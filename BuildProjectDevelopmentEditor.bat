@echo OFF

:: Change the page to UTF-8 for message formatting
chcp 65001 >nul

setlocal enabledelayedexpansion

set "UPROJECT_FILE="

:: List of top-level folders to delete
set "FOLDERS_TO_DELETE=Binaries Intermediate Build DerivedDataCache Saved .vs .idea"

:: List of Plugin folders to delete
set "PLUGIN_FOLDERS_TO_DELETE=Binaries Intermediate"

:: List of top-level files to delete
set "FILES_TO_DELETE=*.sln *.vsconfig"

for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Search for the first .uproject file in the current directory
for %%F in (*.uproject) do (
    set "UPROJECT_FILE=%%F"    
)

if defined UPROJECT_FILE ( 
    echo ✅ Found .uproject file: %ESC%[0;92m!UPROJECT_FILE!%ESC%[0m
) else ( 
    echo ❌ %ESC%[0;91mNo .uproject file found in this folder. Please copy this .bat file to a folder with a .uproject file.%ESC%[0m
    goto :END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Read EngineAssociation from .uproject
for /f "tokens=2 delims=:" %%A in ('findstr "EngineAssociation" "%UPROJECT_FILE%"') do ( 
    set "RAW_ENGINE_VERSION=%%A"
    )

:: Clean up the value (remove quotes, whitespace, comma)
set "ENGINE_VERSION=%RAW_ENGINE_VERSION:~2,-2%"

:: Check if we found it
if defined RAW_ENGINE_VERSION (
    echo ✅ Detected Engine version [MAJOR.MINOR]: %ESC%[0;92m%ENGINE_VERSION%%ESC%[0m
) else (
    echo ❌ %ESC%[0;91mFailed to find Engine version in the !UPROJECT_FILE! file.%ESC%[0m
    goto :END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Read the Engine InstalledDirectory value from the registry
 for /f "tokens=3*" %%A in ('reg query "HKLM\SOFTWARE\EpicGames\Unreal Engine\%ENGINE_VERSION%" /v InstalledDirectory 2^>nul') do (
    set "UNREAL_INS_DIR=%%A %%B"
)

:: Trim leading spaces
set "STR=!UNREAL_INS_DIR!"
for /f "tokens=* delims= " %%A in ("!STR!") do set "STR=%%A"

:: Trim trailing spaces
:TrimTrailing
set "LASTCHAR=!STR:~-1!"
if "!LASTCHAR!"==" " (
    set "STR=!STR:~0,-1!"
    goto TrimTrailing
)

:: Trimmed/ clean directory path
set "UNREAL_INS_DIR=!STR!"

:: Check if the directory path can be found
if defined UNREAL_INS_DIR (
    echo ✅ Unreal Engine %ENGINE_VERSION% install directory found: %ESC%[0;92m!UNREAL_INS_DIR!%ESC%[0m
) else (
    echo ❌ %ESC%[0;91mFailed Unreal Engine %ENGINE_VERSION% install directory.%ESC%[0m
    goto :END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.
echo 🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹

:ASKTOBUILD
echo.
echo A description of what we are going to do 
echo.
echo List of top-level folders to delete: %ESC%[0;33m!FOLDERS_TO_DELETE!%ESC%[0m
echo List of Plugin folders to delete: %ESC%[0;33m!PLUGIN_FOLDERS_TO_DELETE!%ESC%[0m
echo List of top-level files to delete: %ESC%[0;93m!FILES_TO_DELETE!%ESC%[0m
echo.
CHOICE /C YN /M "⚠️ Do you want to continue deleting Binaries?"
echo.

IF %ERRORLEVEL% EQU 1 ( goto BEGINBUILD)
IF %ERRORLEVEL% EQU 2 ( goto END)

:BEGINBUILD


echo 🔄 Cleaning Unreal project folders...

:: Delete top-level folders
for %%F in (%FOLDERS_TO_DELETE%) do (
    if exist "%%F" (
        echo 🧹 Deleting folder: %%F
        rmdir /s /q "%%F"
    ) else (
        echo ⚠️ Folder not found: %%F
    )
)

:: Check for Plugins directory
if exist "Plugins" (
    echo.
    echo 🔍 Searching Plugins for folders to clean...
    for /d /r "Plugins" %%D in (%PLUGIN_FOLDERS_TO_DELETE%) do (
        if exist "%%D" (
            echo 🧹 Deleting plugin folder: %%D
            rmdir /s /q "%%D"
        )
    )
) else (
    echo ⚠️ No Plugins folder found, skipping plugin cleanup.
)

:: Delete .sln and .vsconfig files
echo.
echo 🗑️ Deleting solution and config files...

for %%F in (%FILES_TO_DELETE%) do (
    if exist "%%F" (
        echo 🧹 Deleting file: %%F
        del /q "%%F"
    ) else (
        echo ⚠️ File not found: %%F
    )
)

echo.
echo 🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹
echo.
echo 📄 Generating Visual Studio project files...
echo.

:: Find .uproject Path
set "UPROJECT_DIR=%~dp0"

:: Generate solution .sln
cmd /c call "!UNREAL_INS_DIR!\Engine\Binaries\DotNet\UnrealBuildTool\UnrealBuildTool.exe" -projectfiles -project="!UPROJECT_DIR!\!UPROJECT_FILE!" -progress

IF NOT "%ERRORLEVEL%" == "0" (
    echo.
    echo ❌ Failed to generate Visual Studio project files.
) 
else (
    echo.
    echo ✅ Visual Studio project files successfully generated!
)

echo.
echo 🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹
echo.

:: Get the .uproject name without extension
for %%N in ("!UPROJECT_FILE!") do set "UPROJECT_NAME=%%~nN"

:: Build project

echo 🛠️ Building Development Editor... 
echo.
cmd /c call "!UNREAL_INS_DIR!\Engine\Build\BatchFiles\Build.bat" "!UPROJECT_NAME!Editor" Win64 Development -project="!UPROJECT_DIR!\!UPROJECT_FILE!"

SET "BUILD_EXIT_CODE=%ERRORLEVEL%"

:: Check if build failed
IF NOT "%BUILD_EXIT_CODE%"=="0" (
    echo.
    echo ❌ Build Failed.
    goto:END
) else ( 
    echo.
    echo ✅ Build Succeeded!)


echo.
CHOICE /C YN /M "Do you want to launch !UPROJECT_FILE!?"
echo.

IF %ERRORLEVEL% EQU 1 ( start "" "%UPROJECT_FILE%"
goto :EOF
)
IF %ERRORLEVEL% EQU 2 (
    goto :EOF
    )

:END
echo.
echo Press any key to exit...
pause >nul
endlocal


