# UE Clean Build Launch (UE CBL)
UE Clean Build Launch (UE CBL) is a Windows batch script that simplifies the process of cleaning, building, and launching Unreal Engine C++ projects. This tool is only compatible with projects using the binary (Epic Games Launcher) version of Unreal Engine — it does not support source builds from GitHub.

## ⚠️ Disclaimer
Use at your own risk — the author is not responsible for any lost or damaged files.
Before running this script, make sure you have committed all your changes to source control.

## ⚙️ Features
* Automatic Project Detection: Automatically finds the .uproject file in the current directory.
 
* Engine Version Resolution: Reads the EngineAssociation property from the .uproject file to determine the correct Unreal Engine version.
 
* Engine Installation Lookup: Retrieves the engine installation path from the Windows Registry (only supports Epic Games Launcher versions).
 
* Clean, Build & Launch: Cleans generated folders and files, regenerates solution files, and builds the project. Once complete, optionally launches the project.

## 🚀 Usage
1. Place the UE_CleanBuildLaunch.bat script in the root directory of your Unreal Engine project (the same directory as your .uproject file).

2. Execution:

   * Double-click the UE_CleanBuildLaunch.bat file, or

   * Run it via the command line.

## 📝 Notes

* Customization: You can modify the lists of folders and files to delete by editing the corresponding variables in the script:

        `set "FOLDERS_TO_DELETE=Binaries Intermediate Build DerivedDataCache Saved .vs .idea"`
        
        `set "PLUGIN_FOLDERS_TO_DELETE=Binaries Intermediate"`
        
        `set "FILES_TO_DELETE=*.sln *.vsconfig"`


* Engine Path Detection: The script attempts to locate the Unreal Engine installation directory based on the EngineAssociation specified in the .uproject file. Ensure that the engine version is correctly installed and registered.

