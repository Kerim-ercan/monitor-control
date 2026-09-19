$ErrorActionPreference = 'Stop'

$TaskName = 'POP AOC monitor switcher'
$WatcherPath = Join-Path $PSScriptRoot 'pop-channel-watcher.ps1'

if (-not (Test-Path -LiteralPath $WatcherPath)) {
    throw "Watcher was not found at '$WatcherPath'."
}

$PowerShell = (Get-Command powershell.exe -ErrorAction Stop).Source
$Arguments = '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}"' -f $WatcherPath
$Action = New-ScheduledTaskAction -Execute $PowerShell -Argument $Arguments
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description 'Switch the AOC monitor input when the Logitech POP keyboard changes computer.' -Force | Out-Null
Write-Host "Installed '$TaskName'. Sign out and in again, or start it from Task Scheduler."
