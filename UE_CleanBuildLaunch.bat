@echo OFF
setlocal enabledelayedexpansion

:: Change the page to UTF-8 for message formatting
chcp 65001 >nul

:: For message colouring
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Banner
echo %ESC%[0;36mUNREAL ENGINE CBL [Clean, Build, Launch] v1.1%ESC%[0m %ESC%[0;90mhttps://github.com/sithilas/UE_CBL_CleanBuildLaunch%ESC%[0m
echo %ESC%[0;90mAUTHOR https://www.x.com/sith_au%ESC%[0m
echo %ESC%[0;90m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯%ESC%[0m
echo Unreal Engine CBL is a FREE lightweight tool to clean and build your Unreal Engine C++ project with a single click.
echo This tool only supports Unreal Engine C++ projects using the Epic Games Launcher (binary) version of the engine.
echo ⚠️ %ESC%[0;33mDISCLAIMER: USE AT YOUR OWN RISK — THE AUTHOR IS NOT RESPONSIBLE FOR ANY LOST OR DAMAGED FILES.
echo    PLEASE COMMIT ALL IMPORTANT CHANGES TO SOURCE CONTROL BEFORE RUNNING THIS TOOL.%ESC%[0m
echo %ESC%[0;90m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯%ESC%[0m

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "UPROJECT_FILE="

:: Add or remove files and folders below
:: List of top-level folders to delete
set "FOLDERS_TO_DELETE=Binaries Intermediate Build DerivedDataCache Saved .vs .idea"
:: List of Plugin folders to delete
set "PLUGIN_FOLDERS_TO_DELETE=Binaries Intermediate"
:: List of top-level files to delete
set "FILES_TO_DELETE=*.sln *.vsconfig"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.
echo 🔍 Checking prerequisites...
echo.

:: Search for the first .uproject file in the current directory
for %%F in (*.uproject) do (
    set "UPROJECT_FILE=%%F"    
)

if defined UPROJECT_FILE ( 
    echo ✅ Found .uproject file: %ESC%[0;92m!UPROJECT_FILE!%ESC%[0m 
) else (
    echo ❌ %ESC%[0;91mMissing .uproject file — run this script in a folder with a valid Unreal project.%ESC%[0m
    goto :END
)


:: Get the .uproject name without extension
for %%N in ("!UPROJECT_FILE!") do set "UPROJECT_NAME=%%~nN"

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
    echo ❌ %ESC%[0;91mEngine version not found in !UPROJECT_FILE!.%ESC%[0m
    goto :END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Read the engine InstalledDirectory value from the registry
 for /f "tokens=3*" %%A in ('reg query "HKLM\SOFTWARE\EpicGames\Unreal Engine\%ENGINE_VERSION%" /v InstalledDirectory 2^>nul') do (
    set "UNREAL_INS_DIR=%%A %%B"
)

:: Trim leading spaces
set "STR=!UNREAL_INS_DIR!"
for /f "tokens=* delims= " %%A in ("!STR!") do (
    set "STR=%%A"
)

:: Trim trailing spaces
:TrimTrailing
set "LASTCHAR=!STR:~-1!"
if "!LASTCHAR!"==" " (
    set "STR=!STR:~0,-1!"
    goto TrimTrailing
)

:: Clean directory path
set "UNREAL_INS_DIR=!STR!"

:: Check if the engine directory path can be found
if defined UNREAL_INS_DIR (
    echo ✅ Unreal Engine %ESC%[0;92m%ENGINE_VERSION%%ESC%[0m install directory found: %ESC%[0;92m!UNREAL_INS_DIR!%ESC%[0m
) else (
    echo ❌ %ESC%[0;91mUnreal Engine %ENGINE_VERSION% installation directory not found. Please ensure it is properly installed.%ESC%[0m
    goto :END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Delay (For readability)
timeout /t 2 >nul

echo.
echo %ESC%[0;90m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯%ESC%[0m

:ASKTOBUILD
echo.
echo This tool will perform the following actions to help you prepare your Unreal Engine C++ project for a clean build.
echo.
echo 1. Permanently delete generated folders such as:
echo     - Binaries, Intermediate, Build, Saved, and .vs, Plugin-specific Binaries and Intermediate folders
echo 2. Permanently delete generated solution-related files:
echo     - .sln, .vsconfig
echo.
echo Once cleanup is complete, the script will:
echo   a. Regenerate project files (.sln)
echo   b. Build the Development Editor target
echo   c. Launch the project (optional)
echo.
echo %ESC%[0;90m[The following cleanup targets can be edited in this script file]%ESC%[0m
echo 🔹 List of top-level folders to delete: %ESC%[0;33m!FOLDERS_TO_DELETE!%ESC%[0m
echo 🔹 List of Plugin folders to delete: %ESC%[0;33m!PLUGIN_FOLDERS_TO_DELETE!%ESC%[0m
echo 🔹 List of top-level files to delete: %ESC%[0;93m!FILES_TO_DELETE!%ESC%[0m
echo.
echo %ESC%[0;90m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯%ESC%[0m
echo.

:: Delay (For readability)
timeout /t 2 >nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: List plugins in the project

set /a FolderCount=0
for /D %%F in ("Plugins\*") do (
    set /a FolderCount+=1
)

if exist "Plugins" (
    if !FolderCount! gtr 0 (
        echo 🔌 Plugins detected in %ESC%[0;33m!UPROJECT_NAME!\Plugins%ESC%[0m. They will be rebuilt with the project.
        echo.
        for /D %%D in ("Plugins\*") do (
            if exist "%%D" (
                echo    -- %ESC%[0;92m%%~nxD%ESC%[0m
            )
        )
        echo.
    )
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CHOICE /C YN /M "⚠️ Ready to Clean, Build, and Launch your project"
echo.

IF %ERRORLEVEL% EQU 1 ( goto BEGINBUILD)
IF %ERRORLEVEL% EQU 2 ( goto END)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BEGINBUILD

echo 🔄 Cleaning project top-level folders...

:: Cleaning top-level folders
for %%F in (%FOLDERS_TO_DELETE%) do (
    if exist "%%F" (
        echo 🧹 Deleting folder: %%F
        rmdir /s /q "%%F"
    ) else (
        echo ⚠️ Folder not found: %%F
    )
)

:: Cleaning Plugins directory
if exist "Plugins" (
    echo.
    echo 🔄 Cleaning project plugin folders...
    for /d /r "Plugins" %%D in (%PLUGIN_FOLDERS_TO_DELETE%) do (
        if exist "%%D" (
            echo 🧹 Deleting plugin folder: %%D
            rmdir /s /q "%%D"
        )
    )
) else (
    echo ⚠️ No Plugins folder found, skipping plugin cleanup.
)

:: Cleaning .sln and .vsconfig files
echo.
echo 🔄 Cleaning solution and config files...

for %%F in (%FILES_TO_DELETE%) do (
    if exist "%%F" (
        echo 🧹 Deleting file: %%F
        del /q "%%F"
    ) else (
        echo ⚠️ File not found: %%F
    )
)

echo.
echo ✅ Clean successful!
echo.
echo %ESC%[0;90m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯%ESC%[0m

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.
echo 📄 Generating Visual Studio project files...
echo.

:: Find .uproject Path
set "UPROJECT_DIR=%~dp0"

:: Generate solution .sln
cmd /c call "!UNREAL_INS_DIR!\Engine\Binaries\DotNet\UnrealBuildTool\UnrealBuildTool.exe" -projectfiles -project="!UPROJECT_DIR!\!UPROJECT_FILE!" -progress

IF NOT "%ERRORLEVEL%" == "0" (
    echo.
    echo ❌ %ESC%[0;91mFailed to generate Visual Studio project files.%ESC%[0m
    goto :END
) else (
    echo.
    echo ✅ Visual Studio project files successfully generated!
)

echo.
echo %ESC%[0;90m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯%ESC%[0m
echo.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Build project

echo 🛠️ Building Development Editor... 
echo.
cmd /c call "!UNREAL_INS_DIR!\Engine\Build\BatchFiles\Build.bat" "!UPROJECT_NAME!Editor" Win64 Development -project="!UPROJECT_DIR!\!UPROJECT_FILE!"

SET "BUILD_EXIT_CODE=%ERRORLEVEL%"

:: Check if build failed
IF NOT "%BUILD_EXIT_CODE%"=="0" (
    echo.
    echo ❌ %ESC%[0;91mBuild Failed.%ESC%[0m
    goto:END
) else ( 
    echo.
    echo ✅ Build Succeeded!
)

echo.
echo %ESC%[0;90m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯%ESC%[0m
echo.
CHOICE /C YN /M "Do you want to launch !UPROJECT_FILE!"
echo.

IF %ERRORLEVEL% EQU 1 ( 
    start "" "%UPROJECT_FILE%"
    goto :EOF
)
IF %ERRORLEVEL% EQU 2 (
    goto :EOF
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
echo.
echo Press any key to exit...
pause >nul
endlocal
