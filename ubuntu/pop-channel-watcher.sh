#!/usr/bin/env bash
set -u

# ---------- configuration ----------
KEYBOARD_NAME_PATTERN="${KEYBOARD_NAME_PATTERN:-POP Keys|Logitech}"
POP_KEYBOARD_MAC="${POP_KEYBOARD_MAC:-}"
INPUT_DP="${INPUT_DP:-15}"
POLL_SECONDS="${POLL_SECONDS:-1}"
CONFIRM_SAMPLES="${CONFIRM_SAMPLES:-2}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# ------------------------------------

if ! command -v bluetoothctl >/dev/null 2>&1; then
  echo "bluetoothctl was not found. Install it with: sudo apt install bluez" >&2
  exit 1
fi

keyboard_connected() {
  if [[ -n "$POP_KEYBOARD_MAC" ]]; then
    bluetoothctl info "$POP_KEYBOARD_MAC" 2>/dev/null |
      grep -Eiq '^[[:space:]]*Connected:[[:space:]]*yes'
  else
    bluetoothctl devices Connected 2>/dev/null |
      grep -Eiq "$KEYBOARD_NAME_PATTERN"
  fi
}

set_input() {
  echo "Setting monitor input to DP (VCP 60 value $1)"
  "$SCRIPT_DIR/set-monitor-input.sh" "$1"
}

last_state=0
if keyboard_connected; then
  last_state=1
fi

echo "Watching POP keyboard on Ubuntu. Connected=$last_state"
if [[ "$last_state" -eq 1 ]]; then
  # The watcher may start after Ubuntu has already connected to channel 3.
  set_input "$INPUT_DP"
fi
echo 'Press the POP Easy-Switch channel button to test. Press Ctrl+C to stop.'

while true; do
  sleep "$POLL_SECONDS"
  candidate=0
  if keyboard_connected; then
    candidate=1
  fi

  if [[ "$candidate" -eq "$last_state" ]]; then
    continue
  fi

  stable=1
  i=1
  while (( i < CONFIRM_SAMPLES )); do
    sleep "$POLL_SECONDS"
    check=0
    if keyboard_connected; then
      check=1
    fi
    if [[ "$check" -ne "$candidate" ]]; then
      stable=0
      break
    fi
    (( i++ ))
  done

  if [[ "$stable" -eq 0 ]]; then
    continue
  fi

  if [[ "$candidate" -eq 1 ]]; then
    # POP connected to Ubuntu: select DisplayPort. Do not switch on
    # disconnect; macOS owns the HDMI selection and Windows owns DP too.
    set_input "$INPUT_DP"
  fi

  last_state="$candidate"
done
