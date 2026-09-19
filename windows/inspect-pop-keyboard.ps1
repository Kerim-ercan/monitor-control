$ErrorActionPreference = 'SilentlyContinue'

Write-Host 'Keyboard devices currently known to Windows:' -ForegroundColor Cyan
Get-PnpDevice -Class Keyboard |
    Select-Object Status, FriendlyName, InstanceId |
    Format-Table -AutoSize

Write-Host ''
Write-Host 'Look for the POP/Logitech FriendlyName above. Use a distinctive part of it as KeyboardNamePattern in pop-channel-watcher.ps1.' -ForegroundColor Yellow
