@{
  # Library folders that should be mapped 
  libraryFoldersTarget     = "F:/Windows Libraries/" # Root directory for Libraries below
  libraryFoldersListToMove = @("Downloads", "Documents", "Music", "Pictures", "Saved Games", "Videos")

  # Paths you can change
  startupPath              = "./startup"
  appdataPath              = "./appdata"
  officeConfigPath         = "./office.xml"

  # Automatically downloads and installs all Visual C++ Redists
  redistInstallVcRedist    = $true

  # Winget packages lists, can be found by `winget search ProgramName`
  redistWingetPackages     = $(
    "Microsoft.DotNet.DesktopRuntime.3_1",
    "Microsoft.DotNet.DesktopRuntime.5",
    "Microsoft.DotNet.DesktopRuntime.6",
    "Microsoft.DotNet.DesktopRuntime.7",
    "Microsoft.DotNet.DesktopRuntime.8"
  )

  devToolsWingetPackages   = $(
    "Git.Git",
    "Python.Python.3.11",
    "Kitware.CMake",
    "CoreyButler.NVMforWindows",
    "Google.PlatformTools",
    "Microsoft.VisualStudio.2022.BuildTools"
  )

  otherWingetPackages      = $(
    "7Zip.7Zip",
    "Gyan.FFmpeg",
    "Google.Chrome",
    "Mozilla.Firefox",
    "Discord.Discord",
    "Spotify.Spotify",
    "Obsidian.Obsidian",
    "Nextcloud.NextcloudDesktop",
    "QL-Win.QuickLook",
    "Flameshot.Flameshot",
    "KDE.KDEConnect",
    "VideoLAN.VLC",
    "WireGuard.WireGuard",
    "HermannSchinagl.LinkShellExtension",
    "Guru3D.Afterburner"
  )

  # Choco packages, chocolatey will be installed automatically
  chocoPackages            = $(
    "processhacker",
    "jetbrainstoolbox",
    "cheatengine"
  )

  # List of programs that should be pinned to start menu
  pinToStartList           = @(
    "P:\Programs\Telegram\Telegram.exe",
    "P:\Programs\obs-studio\bin\64bit\obs64.exe",
    "P:\Programs\Steam\steam.exe"
  )

  # List of programs that should be pinned to taskbar
  pinToTaskbarList         = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "P:\Programs\Visual Studio Code\Code.exe",
    "P:\Programs\Sublime Text 4\sublime_text.exe"
  )

  # View available props here under `/x setting value` https://ss64.com/nt/powercfg.html
  powerCfgSettings         = @{
    "monitor-timeout-ac" = 15
    "standby-timeout-ac" = 0
  }

  # List of services that should be stopped and disabled
  disableServicesList      = @(
    "PcaSvc"
  )

  # Explorer settings, sets registry keys in `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`
  explorerSettings         = @{
    "TaskbarGlomLevel"   = 2 # 0 - combine when taskbar is full, 1 - always combine, 2 - never combine
    "MMTaskbarGlomLevel" = 2 # same but for other monitors
    "TaskbarSmallIcons"  = 0 # 0 - large icons, 1 - small icons
    "TaskbarLockAll"     = 1 # 0 - unlock the taskbar, 1 - lock the taskbar
    "TaskbarDa"          = 0 # 0 - remove widgets from taskbar, 1 - add widgets to taskbar
    "TaskbarSd"          = 0 # 0 - disable show desktop button, 1 - enable show desktop button
    "TaskbarAl"          = 0 # 0 - icons to left, 1 - icons to center
    "MMTaskbarMode"      = 2 # 0 - show taskbar icons on all displays, 1 - show all on main display and display where window is opened, 2 - only where window is opened
    "UseCompactMode"     = 1 # 0 - big paddings in explorer, 1 - classic paddings from win 7/8/10 etc.
    "ShowTaskViewButton" = 0
    "ShowInfoTip"        = 0
  }

  # List of uwp apps that should be uninstalled, can be listed by `Get-AppxPackage -AllUsers | Select Name, PackageFullName`
  uwpUninstallList         = $(
    "Microsoft.People",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.549981C3F5F10"
  )

  # Custom symlinks
  # original = folder/file to replace by simlink
  # link = folder/file that should be dropped to `original` as symlink
  symlinks                 = @(
    @{
      original = "C:\Program Files (x86)\MSI Afterburner\Porfiles"
      link     = "P:\Data\msi-afterburner-profiles"
    }
  )
}
