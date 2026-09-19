# AOC 24G42E + Logitech POP three-OS switcher

This setup makes the POP Keys' existing Easy-Switch buttons switch both:

- the keyboard connection: macOS ↔ Windows ↔ Ubuntu;
- the AOC 24G42E input: DisplayPort ↔ HDMI.

The monitor must have `Menu → Settings → DDC/CI → Yes` enabled.

Use one of the POP's hardware Easy-Switch buttons (normally F1, F2, or F3). A remapped emoji/custom key cannot itself change the POP's Bluetooth channel because Logitech does not expose that hardware channel action as a software shortcut.

The intended pairing is:

| POP channel | Operating system | AOC input |
|---|---|---|
| 1 | macOS | HDMI |
| 2 | Windows | DisplayPort |
| 3 | Ubuntu | DisplayPort |

## Important assumptions

- The POP keyboard is paired through Bluetooth on all three operating systems. Do not use a Logi Bolt receiver for the watched connection; the receiver can remain present even when the keyboard changes channel.
- Windows and Ubuntu may be two operating systems on the same desktop. Only the currently booted operating system needs its watcher running.
- The monitor is the primary display on Windows and is display `1` for `m1ddc` on macOS.
- The monitor is display `1` for `ddcutil` on Ubuntu.

If your channel assignments differ, the watchers still map macOS to HDMI and Windows/Ubuntu to DisplayPort; only the button numbers change.

## Input values

The scripts default to the usual MCCS values:

- DP: `15`
- HDMI 1: `17`

Input values are monitor-specific. If either command does nothing, open ControlMyMonitor on Windows, select the AOC, locate VCP code `60` (`Input Source`), and use the DP/HDMI values it reports when editing the scripts.

## Windows setup

1. Download and extract [ControlMyMonitor](https://www.nirsoft.net/utils/control_my_monitor.html), for example to `C:\Tools\ControlMyMonitor`.
2. Open PowerShell in this folder and run:

   ```powershell
   .\windows\inspect-pop-keyboard.ps1
   ```

   Confirm that the POP appears as a keyboard and copy the displayed `FriendlyName` pattern if necessary.
3. Test the monitor command manually. Edit the executable path in `windows\set-monitor-input.ps1` first, then run:

   ```powershell
   .\windows\set-monitor-input.ps1 -InputValue 17
   .\windows\set-monitor-input.ps1 -InputValue 15
   ```

4. Edit the configuration at the top of `windows\pop-channel-watcher.ps1` if needed. This watcher treats a connected POP keyboard as Windows/channel 2 and selects DisplayPort. Start it with:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows\pop-channel-watcher.ps1
   ```

Leave this window running while testing. After it works, add the watcher to Windows startup or Task Scheduler.

To install it to start automatically when you sign in, run PowerShell as your normal user:

```powershell
.\windows\install-startup.ps1
```

To remove that startup task later:

```powershell
.\windows\uninstall-startup.ps1
```

## macOS setup

Install Homebrew tools once:

```zsh
brew install blueutil m1ddc
```

Make the macOS scripts executable once:

```zsh
chmod +x macos/*.sh ubuntu/*.sh
```

Connect the AOC to the Mac and inspect the available displays:

```zsh
m1ddc display list
blueutil --connected
```

Edit the values near the top of `macos/set-monitor-input.sh` if necessary, then test:

```zsh
./macos/set-monitor-input.sh 17
./macos/set-monitor-input.sh 15
```

Confirm that the POP name appears in `blueutil --connected`, then start the watcher:

```zsh
./macos/pop-channel-watcher.sh
```

The watcher can be installed as a background Login Item with:

```zsh
./macos/install-launch-agent.sh
```

The installer uses the current workspace path. If the folder is moved later, run the installer again.

## Ubuntu setup

Install Bluetooth and DDC/CI support:

```bash
sudo apt update
sudo apt install bluez bluetooth ddcutil
sudo systemctl enable --now bluetooth
```

Check that Ubuntu can see the monitor and the POP keyboard:

```bash
ddcutil detect
ddcutil vcpinfo 60 --verbose
bluetoothctl devices Paired
bluetoothctl devices Connected
```

If `ddcutil detect` finds more than one display, change `DDCUTIL_DISPLAY` near the top of `ubuntu/set-monitor-input.sh`. If the POP name is not shown exactly as `POP Keys`, set `KEYBOARD_NAME_PATTERN` near the top of `ubuntu/pop-channel-watcher.sh`. For a more reliable match, put the keyboard address from `bluetoothctl devices Paired` into `POP_KEYBOARD_MAC`.

Test the DP command:

```bash
./ubuntu/set-monitor-input.sh 15
```

Then start the watcher. It treats a connected POP keyboard as Ubuntu/channel 3 and selects DisplayPort:

```bash
./ubuntu/pop-channel-watcher.sh
```

After testing, install it as a user systemd service:

```bash
./ubuntu/install-user-service.sh
```

Remove it later with:

```bash
./ubuntu/uninstall-user-service.sh
```

## How to use it

After the watchers are installed:

- press POP channel 1 for macOS; the monitor should select HDMI;
- press POP channel 2 for Windows; the monitor should select DisplayPort;
- press POP channel 3 for Ubuntu; the monitor should select DisplayPort.

The watchers also select their input if they start while the POP is already connected. Switching Windows ↔ Ubuntu does not need a monitor change because both use DisplayPort. If the keyboard's sleep behavior causes unwanted switches, increase `ConfirmSamples` in the Windows script or `CONFIRM_SAMPLES` in the macOS/Ubuntu scripts.

## Limitations

This is an automation around three independent Bluetooth connections; Logitech does not provide a native POP action that changes a monitor input. Some USB-C-to-HDMI adapters block DDC/CI, and some monitor firmware accepts DDC commands only from the currently selected input. If the monitor changes in one direction but not the other, a hardware video switch/KVM is the reliable fallback.
