#!/bin/zsh
set -e

AGENT_PATH="$HOME/Library/LaunchAgents/com.local.pop-monitor-switcher.plist"

if [[ -f "$AGENT_PATH" ]]; then
  launchctl bootout "gui/$(id -u)" "$AGENT_PATH" 2>/dev/null || true
  rm "$AGENT_PATH"
  print "Removed $AGENT_PATH"
else
  print "No installed POP monitor switcher was found."
fi
