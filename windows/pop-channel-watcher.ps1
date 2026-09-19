$ErrorActionPreference = 'SilentlyContinue'

# ---------- configuration ----------
$ControlMyMonitor = 'C:\Tools\ControlMyMonitor\ControlMyMonitor.exe'
$MonitorTarget = 'Primary'
$InputDP = 15
$KeyboardNamePattern = 'POP|Logitech'
$PollSeconds = 1
$ConfirmSamples = 2
# ------------------------------------

function Get-PopKeyboardConnected {
    $devices = @(Get-PnpDevice -PresentOnly -Class Keyboard | Where-Object {
        $_.FriendlyName -match $KeyboardNamePattern
    })

    return @($devices | Where-Object { $_.Status -eq 'OK' }).Count -gt 0
}

function Set-MonitorInput([int] $value) {
    if (-not (Test-Path -LiteralPath $ControlMyMonitor)) {
        throw "ControlMyMonitor.exe was not found at '$ControlMyMonitor'."
    }

    Write-Host "Setting monitor input VCP 60 to $value"
    & $ControlMyMonitor /SetValue $MonitorTarget 60 $value | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "ControlMyMonitor returned exit code $LASTEXITCODE"
    }
}

$initialDevices = @(Get-PnpDevice -Class Keyboard | Where-Object {
    $_.FriendlyName -match $KeyboardNamePattern
})

if ($initialDevices.Count -eq 0) {
    throw "No keyboard matched '$KeyboardNamePattern'. Run inspect-pop-keyboard.ps1 and update KeyboardNamePattern."
}

$last = Get-PopKeyboardConnected
Write-Host "Watching POP keyboard. Connected=$last"
Write-Host 'Windows maps a connected POP keyboard to DisplayPort.'
Write-Host 'Press the POP Easy-Switch channel button to test. Press Ctrl+C to stop.'

if ($last) {
    # The watcher may start after Windows has already connected to channel 2.
    Set-MonitorInput $InputDP
}

while ($true) {
    Start-Sleep -Seconds $PollSeconds
    $candidate = Get-PopKeyboardConnected

    if ($candidate -eq $last) {
        continue
    }

    # Require the new state to survive several samples so a transient
    # Bluetooth event does not immediately change the monitor.
    $stable = $true
    for ($i = 1; $i -lt $ConfirmSamples; $i++) {
        Start-Sleep -Seconds $PollSeconds
        if ((Get-PopKeyboardConnected) -ne $candidate) {
            $stable = $false
            break
        }
    }

    if (-not $stable) {
        continue
    }

    if ($candidate) {
        # POP connected to Windows: select DisplayPort. Do not switch on
        # disconnect: the target operating system has its own positive
        # connection watcher and selects its required input.
        Set-MonitorInput $InputDP
    }

    $last = $candidate
}
