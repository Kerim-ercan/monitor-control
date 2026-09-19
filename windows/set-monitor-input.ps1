param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(0, 255)]
    [int] $InputValue
)

# Change this if ControlMyMonitor.exe is stored elsewhere.
$ControlMyMonitor = 'C:\Tools\ControlMyMonitor\ControlMyMonitor.exe'

# Use 'Primary' for the primary monitor, or replace it with the monitor
# identifier shown by ControlMyMonitor (for example ".\\DISPLAY1\\Monitor0").
$MonitorTarget = 'Primary'

if (-not (Test-Path -LiteralPath $ControlMyMonitor)) {
    throw "ControlMyMonitor.exe was not found at '$ControlMyMonitor'. Edit this script's path."
}

& $ControlMyMonitor /SetValue $MonitorTarget 60 $InputValue | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "ControlMyMonitor failed with exit code $LASTEXITCODE. Check DDC/CI and the monitor target."
}
