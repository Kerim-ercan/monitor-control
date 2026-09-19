$ErrorActionPreference = 'Stop'

$TaskName = 'POP AOC monitor switcher'
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "Removed '$TaskName' if it existed."
