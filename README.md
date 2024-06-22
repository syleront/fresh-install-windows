# AIO fresh-install script

I'm tired of configuring everything again every time after reinstalling Windows - installing edits, necessary programs, disabling elements I don't need, and so on. Therefore, it was decided to automate most of the steps that are required after a fresh installation of Windows.

## Disclaimer

This script was created for personal use, and I take no responsibility for the result you get when using this script.

## Requirements

* Actual build of Windows 10/11
* `winget` (should be installed by default)
* Run the script with administrative privileges. I have not tested it using the default user.

## Available flags

* `-h` - print available flags
* `-all` - set all flags below to true
* `-moveLibraryFolders` - moves **configured** libraries from `%USERPROFILE%` to the  **configured** target folder
  * `config -> libraryFoldersTarget`
  * `config -> libraryFoldersListToMove`
* `-installRedist` - automatically downloads and installs all Visual C++ redistributables [(link)](https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/), and your **configured** winget packages
  * `config -> redistInstallVcRedist`
  * `config -> redistWingetPackages`
* `-installDevTools` - installs your **configured** dev packages
  * `config -> devToolsWingetPackages`
* `-installOther` - installs your **configured** other packages
  * `config -> otherWingetPackages`
* `-installChocoExtras` - installs your **configured** packages from chocolatey (choco will be installed in your system automatically)
  * `config -> chocoPackages`
* `-chromeAsDefault` - set chrome as default browser
* `-wsl` - install Windows Susbsystem for Linux and set default version to 2
* `-pinPrograms` - pin your **configured** programs to taskbar/start menu
  * `config -> pinToStartList`
  * `config -> pinToTaskbarList`
* `-powercfg` - apply powercfg props
  * `config -> powerCfgSettings`
* `-startup` - copy shortcuts from `./startup` to `shell:startup`
* `-appdata` - create symlinks for AppData folders located in `./appdata/Roaming` and `./appdata/Local`
  * > **HOW IT WORKS:** For example, if you place a folder named `obs-studio` in the `appdata/Roaming` directory, then if there is already a folder with the same name in the `%APPDATA%` directory, it ***will be removed*** and a symbolic link will be created to the `./appdata/Roaming/obs-studio`, so the final result will be `%APPDATA%/obs-studio` -> `./appdata/Roaming/obs-studio`.
* `-activate` - activate Windows using the HWID method ([source](https://bitbucket.org/WindowsAddict/microsoft-activation-scripts/))
* `-setExplorerSettings` - set explorer settings through registry
  * `config -> explorerSettings`
* `-disableDefender` - disable windows defender using `dControl`
  * > **WARNING:** You will be asked to disable real-time protection in Windows Defender. After that, the script will unpack and run the dControl, and you will need to manually interact with dControl to disable Windows Defender.
* `-disableServices` - disable selected services
  * `config -> disableServicesList`
* `-disableWin11Context` - disable the new Windows 11 context menu
* `-disableRecentsInExplorer` - disable recent folders/docs/files in explorer
* `-uninstallOneDrive` - uninstall the OneDrive app and remove from explorer
* `-uninstallUwpApps` - uninstall UWP apps
  * `config -> uwpUninstallList`

## Credits

* [technosys.net](https://www.technosys.net/products/utils/pintotaskbar) - syspin.exe
* [kolbi.cz](https://kolbi.cz/blog/2017/11/10/setdefaultbrowser-set-the-default-browser-per-user-on-windows-10-and-server-2016-build-1607/) - SetDefaultBrowser.exe
* [sordum.org](https://www.sordum.org/9480/defender-control-v2-1/) - Defender Control
* [7-zip.org](https://www.7-zip.org/download.html) - 7z.exe
* [YoraiLevi](https://gist.github.com/YoraiLevi/0f333d520f502fdb1244cdf0524db6d2) - KnownFolderPath script
