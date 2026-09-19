#!/usr/bin/env bash
set -u

# ddcutil uses VCP code 60 for Input Source. Values are usually DP=15
# and HDMI 1=17, but use the values reported by your monitor if different.
DDCUTIL_DISPLAY="${DDCUTIL_DISPLAY:-1}"
DDCUTIL_BIN="${DDCUTIL_BIN:-$(command -v ddcutil 2>/dev/null || true)}"

if [[ -z "$DDCUTIL_BIN" ]]; then
  echo "ddcutil was not found. Install it with: sudo apt install ddcutil" >&2
  exit 1
fi

if [[ $# -ne 1 || ! "$1" =~ ^(0[xX])?[0-9a-fA-F]+$ ]]; then
  echo "Usage: $0 INPUT_VALUE" >&2
  exit 2
fi

exec "$DDCUTIL_BIN" --display "$DDCUTIL_DISPLAY" setvcp 60 "$1"
