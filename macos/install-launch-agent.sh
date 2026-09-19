#!/bin/zsh
set -e

SCRIPT_DIR="${0:A:h}"
AGENT_DIR="$HOME/Library/LaunchAgents"
AGENT_PATH="$AGENT_DIR/com.local.pop-monitor-switcher.plist"

mkdir -p "$AGENT_DIR"

python3 - "$AGENT_PATH" "$SCRIPT_DIR/pop-channel-watcher.sh" <<'PY'
import plistlib
import sys

plist_path, script_path = sys.argv[1:]
data = {
    "Label": "com.local.pop-monitor-switcher",
    "ProgramArguments": ["/bin/zsh", script_path],
    "RunAtLoad": True,
    "KeepAlive": True,
    "StandardOutPath": "/tmp/pop-monitor-switcher.log",
    "StandardErrorPath": "/tmp/pop-monitor-switcher.err",
}
with open(plist_path, "wb") as f:
    plistlib.dump(data, f)
PY

launchctl bootout "gui/$(id -u)" "$AGENT_PATH" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$AGENT_PATH"
print "Installed and started $AGENT_PATH"
