#!/bin/bash
exec > /tmp/start.log 2>&1
echo "=== Start at $(date) ==="

export DISPLAY=:99
export HOME=/root

# Kill existing
pkill -f Xvfb 2>/dev/null || true
pkill -f x11vnc 2>/dev/null || true
pkill -f fluxbox 2>/dev/null || true
pkill -f websockify 2>/dev/null || true
sleep 1

# Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 -ac &
sleep 2

# Start window manager
fluxbox &
sleep 1

# Start VNC
x11vnc -display :99 -forever -nopw -quiet -rfbport 5900 -shared -localhost &
sleep 2

# Start noVNC
cd /opt/noVNC && { ./utils/novnc_proxy --vnc localhost:5900 --listen 6080 & }
sleep 2

echo "=== Services started ==="
ss -tlnp | grep -E '5900|6080'
