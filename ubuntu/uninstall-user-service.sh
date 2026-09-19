#!/usr/bin/env bash
set -e

SERVICE_NAME='pop-monitor-switcher.service'
SERVICE_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/$SERVICE_NAME"

systemctl --user disable --now "$SERVICE_NAME" 2>/dev/null || true
rm -f "$SERVICE_PATH"
systemctl --user daemon-reload
echo "Removed $SERVICE_NAME if it was installed."
