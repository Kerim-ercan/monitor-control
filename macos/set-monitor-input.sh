#!/bin/zsh
set -u

# LaunchAgents receive a minimal PATH; include both common Homebrew locations.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# m1ddc uses common MCCS values: DP=15, HDMI 1=17.
# Change these if the monitor reports different values.
M1DDC_DISPLAY="${M1DDC_DISPLAY:-1}"
M1DDC_BIN="${M1DDC_BIN:-$(command -v m1ddc 2>/dev/null || true)}"

if [[ -z "$M1DDC_BIN" ]]; then
  print -u2 "m1ddc was not found. Install it with: brew install m1ddc"
  exit 1
fi

if [[ $# -ne 1 || "$1" != <-> ]]; then
  print -u2 "Usage: $0 INPUT_VALUE"
  exit 2
fi

exec "$M1DDC_BIN" display "$M1DDC_DISPLAY" set input "$1"
