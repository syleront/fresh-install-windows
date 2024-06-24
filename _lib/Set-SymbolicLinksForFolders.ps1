function Set-SymbolicLinksForFolders {
  Param (
    [Parameter(Mandatory = $true)]
    [string]$From,
    [Parameter(Mandatory = $true)]
    [string]$To
  )
  if (Test-Path -Path $From) {
    $foldersToLink = Get-ChildItem -Path $From -Directory
    foreach ($folderToLink in $foldersToLink) {
      $original = Join-Path $To -ChildPath $folderToLink
      Set-SymbolicLink $folderToLink.FullName $original
    }
  }
  else {
    Write-Warning "Not found path $From"
  }
}

function Set-SymbolicLink {
  Param (
    [Parameter(Mandatory = $true)]
    [string]$Source,
    [Parameter(Mandatory = $true)]
    [string]$DropTo
  )
  if (Test-Path -Path $Source) {
    if (Test-Path -Path $DropTo) {
      Write-Warning "Remove existing $DropTo"
      if (-not (Test-Symlink $DropTo)) {
        Remove-Item -Recurse $DropTo
      } else {
        (Get-Item $DropTo).Delete()
      }
    }

    New-Item -ItemType SymbolicLink -Path $DropTo -Value $Source > $null
    Grant-Permissions $Source > $null
    Grant-Permissions $DropTo > $null
    Write-Output "Created symlink $Source -> $DropTo"
  } else {
    Write-Warning "Not found folder to drop as symlink: $Source"
  }
}

function Test-Symlink([string]$path) {
  $file = Get-Item $path -Force -ea SilentlyContinue
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}
