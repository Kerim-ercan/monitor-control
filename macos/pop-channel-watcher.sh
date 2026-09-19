#!/bin/zsh
set -u

# LaunchAgents receive a minimal PATH; include both common Homebrew locations.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ---------- configuration ----------
KEYBOARD_NAME_PATTERN="${KEYBOARD_NAME_PATTERN:-POP Keys|Logitech}"
INPUT_HDMI="${INPUT_HDMI:-17}"
POLL_SECONDS="${POLL_SECONDS:-1}"
CONFIRM_SAMPLES="${CONFIRM_SAMPLES:-2}"
SCRIPT_DIR="${0:A:h}"
# ------------------------------------

if ! command -v blueutil >/dev/null 2>&1; then
  print -u2 "blueutil was not found. Install it with: brew install blueutil"
  exit 1
fi

keyboard_connected() {
  blueutil --connected 2>/dev/null | grep -Eiq "$KEYBOARD_NAME_PATTERN"
}

set_input() {
  print "Setting monitor input to VCP 60 value $1"
  "$SCRIPT_DIR/set-monitor-input.sh" "$1"
}

last_state=0
if keyboard_connected; then
  last_state=1
fi

print "Watching POP keyboard. Connected=$last_state"
if [[ "$last_state" -eq 1 ]]; then
  # The watcher may start after macOS has already connected to channel 1.
  set_input "$INPUT_HDMI"
fi
print 'Press the POP Easy-Switch channel button to test. Press Ctrl+C to stop.'

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
  integer i=1
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
    # POP connected to macOS: select HDMI. Do not switch on disconnect;
    # Windows and Ubuntu have their own positive connection watchers.
    set_input "$INPUT_HDMI"
  fi

  last_state="$candidate"
done
