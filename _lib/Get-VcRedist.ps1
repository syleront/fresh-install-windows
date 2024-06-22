# https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/
function Get-VcRedist {
  Param (
    [Parameter(Mandatory = $true)]
    [string]$outFile
  )
  $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
  $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
  Invoke-WebRequest -UseBasicParsing -Uri "https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/" `
    -Method "POST" `
    -WebSession $session `
    -ContentType "application/x-www-form-urlencoded" `
    -Body "id=2630&server_id=8" -OutFile $outFile
}
