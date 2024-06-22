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
      $originalFolder = Join-Path $To -ChildPath $folderToLink

      if (Test-Path -Path $originalFolder) {
        Remove-Item -Recurse $originalFolder
      }

      Write-Host "Created symlink $($folderToLink.FullName) -> $originalFolder"
      New-Item -ItemType SymbolicLink -Path $originalFolder -Value $folderToLink.FullName
    }
  } else {
    Write-Warning "Not found folder $From"
  }
}