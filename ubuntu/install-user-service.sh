#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
SERVICE_PATH="$SERVICE_DIR/pop-monitor-switcher.service"

mkdir -p "$SERVICE_DIR"

python3 - "$SERVICE_PATH" "$SCRIPT_DIR/pop-channel-watcher.sh" <<'PY'
from pathlib import Path
import sys

service_path, watcher_path = sys.argv[1:]
service = f'''[Unit]
Description=Switch AOC monitor input for the Logitech POP keyboard

[Service]
Type=simple
ExecStart=/usr/bin/env bash {watcher_path}
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
'''
Path(service_path).write_text(service)
PY

systemctl --user daemon-reload
systemctl --user enable --now pop-monitor-switcher.service
echo "Installed and started $SERVICE_PATH"
