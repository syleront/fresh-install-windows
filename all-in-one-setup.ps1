param (
  [switch]$all,                             # Set all to true
  [switch]$moveLibraryFolders = $all,       
  [switch]$installRedist = $all,            # config -> redistInstallVcRedist, config -> redistWingetPackages
  [switch]$installDevTools = $all,          # config -> devToolsWingetPackages
  [switch]$installOther = $all,             # config -> otherWingetPackages
  [switch]$installChocoExtras = $all,       # config -> chocoPackages
  [switch]$chromeAsDefault = $all,          # sets chrome as default
  [switch]$wsl = $all,                      # install Windows Susbsystem for Linux
  [switch]$pinPrograms = $all,              # pin programs to taskbar/start menu | config -> pinToStartList, config -> pinToTaskbarList
  [switch]$powercfg = $all,                 # apply powercfg props | config -> powerCfgSettings
  [switch]$startup = $all,                  # copy shortcuts from `./startup` to `shell:startup`
  [switch]$appdata = $all,                  # create symlinks for AppData folders placed in ./appdata/Roaming and ./appdata/Local
  [switch]$activate = $all,                 # activate windows using HWID
  [switch]$setExplorerSettings = $all,      # set explorer settings through registry | config -> explorerSettings
  [switch]$disableDefender = $all,          # disable windows defender using dControl
  [switch]$disableServices = $all,          # disable selected services (from config)
  [switch]$disableWin11Context = $all,      # disable new Windows 11 context menu
  [switch]$disableRecentsInExplorer = $all, # disable recent folders/docs/files in explorer
  [switch]$uninstallOneDrive = $all,        # uninstall OneDrive app and remove from explorer
  [switch]$uninstallUwpApps = $all,         # uninstall uwp apps (from config)
  [switch]$h
)

if ($h) {
  Get-Help $MyInvocation.MyCommand.Path -Full
  return
}

$folders = @{
  lib      = "./_lib"
  packages = "./_packages"
  temp     = "./tmp"
  startup  = "./startup"
  appdata  = "./appdata"
}

$packages = @{
  _7z               = Join-Path $folders.packages "7z.exe"
  setDefaultBrowser = Join-Path $folders.packages "SetDefaultBrowser.exe"
  syspin            = Join-Path $folders.packages "syspin.exe"
  dControl          = Join-Path $folders.packages "so7036c.rar"
}

$config = Import-PowerShellDataFile -Path .\config.psd1
Import-Module -Name (Join-Path $folders.lib "Get-VcRedist.ps1") -Force
Import-Module -Name (Join-Path $folders.lib "KnownFolderPathPS5.ps1") -Force
Import-Module -Name (Join-Path $folders.lib "Set-SymbolicLinksForFolders.ps1") -Force

# == Move library folders ==
if ($moveLibraryFolders) {
  Write-Host "Set library folders"
  foreach ($library in $config.libraryFoldersListToMove) {
    Set-KnownFolderPathWrapper $library (Join-Path $config.libraryFoldersTarget $library)
  }
}

# == Install redists ==
if ($installRedist) {
  Write-Host "Installing redists"

  if ($config.redistInstallVcRedist) {
    $outFile = Join-Path $folders.temp "vcredist.zip"
    $outFolder = Join-Path $folders.temp "vcredist"
    $installAllBat = Join-Path $outFolder "install_all.bat"

    Get-VcRedist -OutFile $outFile
    if (-Not (Test-Path $outFolder)) {
      New-Item -ItemType Directory -Path $outFolder > $null
    }
    & $packages._7z x -o"$outFolder" "$outFile" -y > $null
    Start-Process -FilePath $installAllBat -Wait
  }

  foreach ($package in $config.redistWingetPackages) {
    winget install $package
  }
}

# == Install devtools ==
if ($installDevTools) {
  Write-Host "Installing dev tools"
  foreach ($package in $config.devToolsWingetPackages) {
    winget install $package
  }
}

# == Install other packages ==
if ($installOther) {
  Write-Host "Installing other packages"
  foreach ($package in $config.otherWingetPackages) {
    winget install $package
  }
}

# == Install packages from choco ==
if ($installChocoExtras) {
  Write-Host "Installing extras from choco"
  winget install Chocolatey.Chocolatey
  foreach ($package in $config.chocoPackages) {
    choco install $package -y
  }
}

# == Set default browser ==
if ($chromeAsDefault) {
  # https://kolbi.cz/blog/2017/11/10/setdefaultbrowser-set-the-default-browser-per-user-on-windows-10-and-server-2016-build-1607/
  Write-Host "Set chrome as default"
  Start-Process (Join-Path $folders.packages "SetDefaultBrowser.exe") "chrome" -Wait
}

# == Pin programs to start and taskbar ==
if ($pinPrograms) {
  Write-Host "Pin programs"

  foreach ($item in $config.pinToStartList) {
    if (Test-Path $item) {
      & $packages.syspin $item "Pin to start" > $null
    }
    else {
      Write-Warning "Path for pinning doesn't exists: $item"
    }
  }

  foreach ($item in $config.pinToTaskbarList) {
    if (Test-Path $item) {
      & $packages.syspin $item "Pin to taskbar" > $null
    }
    else {
      Write-Warning "Path for pinning doesn't exists: $item"
    }
  }
}

# == set sleep settings ==
if ($powercfg) {
  foreach ($key in $config.powerCfgSettings.Keys) {
    Powercfg /Change $key $config.powerCfgSettings[$key]
  }
}

# == WSL ==
if ($wsl) {
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
  Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
  wsl --install
  wsl --set-default-version 2
}

# == Defender ==
if ($disableDefender) {
  $agreement = $false

  $userInput = Read-Host "It's necessary to disable Windows Defender real-time protection. OK? [Y/ctrl+c]"
  if ($userInput -eq '' -Or $userInput -eq 'y' -Or $userInput -eq 'Y') {
    Write-Host "Disable Real-Time protection in the defender settings, and then the script will automatically continue execution."
    $agreement = $true
  }
  else {
    Write-Host "Disabling the defender has been aborted."
  }
  
  if ($agreement) {
    # Open defender settings if defender service is not stopped
    if (-not (Get-Service -Name WinDefend).Status -eq "Stopped") {
      Start-Process -FilePath "cmd.exe" -ArgumentList "/c start windowsdefender:" -PassThru
      while (!(Get-MpPreference).DisableRealtimeMonitoring) {
        Start-Sleep -Seconds 1
      }
    }

    # Unarchive dControl
    $archive = $packages.dControl
    $dConOut = Join-Path $folders.temp "dcon"
    $executable = Join-Path $dConOut "$([System.IO.Path]::GetFileNameWithoutExtension($archive))/dControl.exe"
    if (-Not (Test-Path -Path $dConOut)) {
      New-Item -ItemType Directory -Path $dConOut > $null
    }
    & $packages._7z x -o"$dConOut" -psordum "$archive" -y > $null

    # Start, wait for the user to close it, remove unpacked folder
    Write-Host "Disable defender and close dControl"
    Start-Process -FilePath $executable -Wait
    Remove-Item -Recurse -Path $dConOut
  }
}

# == Add items to startup ==
if ($startup) {
  $startupPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
  Copy-Item -Path (Join-Path $folders.startup "*") -Destination $startupPath -Force > $null
}

# == Link AppData folders ==
if ($appdata) {
  Write-Host "Linking AppData folders"
  Set-SymbolicLinksForFolders -From (Join-Path $folders.appdata "Roaming") -To $env:APPDATA > $null
  Set-SymbolicLinksForFolders -From (Join-Path $folders.appdata "Local") -To $env:LOCALAPPDATA > $null
}

# == Activate Windows ==
if ($activate) {
  Write-Host "Activating Windows using HWID"
  $activator = Join-Path $folders.temp activate-hwid.cmd
  $url = "https://bitbucket.org/WindowsAddict/microsoft-activation-scripts/raw/master/MAS/Separate-Files-Version/Activators/HWID_Activation.cmd"
  Invoke-WebRequest -Uri $url -OutFile $activator > $null
  Start-Process $activator -Wait
  Remove-Item $activator > $null
}

# == Disable Services ==
if ($disableServices) {
  foreach ($service in $config.disableServicesList) {
    Get-Service $service | Stop-Service -PassThru | Set-Service -StartupType Disabled
  }
}

# == Disable Windows 11 context menu ==
if ($disableWin11Context) {
  $isWin11 = (Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11"
  if ($isWin11) {
    Write-Host "Disable new context menu"
    reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
  }
  else {
    Write-Warning "Disable new context menu available only in Windows 11"
  }
}

# == Disable recent folders/files/documents in explorer ==
if ($disableRecentsInExplorer) {
  Write-Host "Disable recents in explorer"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0
}

# == Set exporer settings through registry ==
if ($setExplorerSettings) {
  foreach ($key in $config.explorerSettings.Keys) {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name $key -Value $config.explorerSettings[$key]
  }
}

# == Uninstall OneDrive ==
if ($uninstallOneDrive) {
  # Stop the OneDrive process
  Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue

  # Uninstall OneDrive
  if (Test-Path "$env:SYSTEMROOT\System32\OneDriveSetup.exe") {
    & "$env:SYSTEMROOT\System32\OneDriveSetup.exe" /uninstall
  }
  elseif (Test-Path "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe") {
    & "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe" /uninstall
  }

  # Remove OneDrive folders and files
  Remove-Item -Path "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue

  # Remove OneDrive from the Explorer sidebar
  $shell = New-Object -ComObject Shell.Application
  $onedriveFolder = $shell.Namespace('shell:::{018D5C66-4533-4307-9B53-224DE2ED1FE6}').Self.Name
  if ($onedriveFolder -eq "OneDrive") {
    $shell.Namespace('shell:::{018D5C66-4533-4307-9B53-224DE2ED1FE6}').Self.InvokeVerb("unpinfromhome")
  }
}

# == Uninstall some unnecessary default apps
if ($uninstallUwpApps) {
  foreach ($app in $config.uwpUninstallList) {
    Get-AppxPackage -AllUsers $app | Remove-AppxPackage
  }
}

# == Restart explorer if needed ==
if ($disableNewContext -Or $disableRecentInExplorer -Or $setExplorerSettings) {
  Stop-Process -Name explorer
  Start-Process explorer
}

# == Reboot PC if needed ==
if ($wsl) {
  while ($true) {
    $userInput = Read-Host "It's necessary to reboot your computer in order to ensure proper functionality. Reboot? [y/n]"
    if ($userInput -eq 'y' -Or $userInput -eq 'Y') {
      Restart-Computer
    }
    elseif ($userInput -eq 'n' -Or $userInput -eq 'N') {
      break
    }
    else {
      Write-Host "Enter y or n"
    }
  }
}

# == Temp folder cleanup
if (Test-Path $folders.temp) {
  Remove-Item -Recurse $folders.temp > $null
}

# TODO
# set default apps for file types
