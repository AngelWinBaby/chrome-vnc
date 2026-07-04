#!/bin/bash
exec > /tmp/start.log 2>&1
echo "=== Start $(date) ==="

export DISPLAY=:99

# Make sure SSH is running
/usr/sbin/sshd 2>/dev/null || true

# Kill old processes
pkill -f Xvfb 2>/dev/null || true
pkill -f x11vnc 2>/dev/null || true
pkill -f fluxbox 2>/dev/null || true
sleep 1

# Xvfb
Xvfb :99 -screen 0 1920x1080x24 -ac &
sleep 2

# Fluxbox
fluxbox &
sleep 1

# x11vnc
x11vnc -display :99 -forever -nopw -quiet -rfbport 5900 -shared &
sleep 2

# noVNC
cd /opt/noVNC && { ./utils/novnc_proxy --vnc localhost:5900 --listen 6080 & }
sleep 2

echo "=== Service status ==="
ss -tlnp | grep -E '5900|6080|22'
echo "=== SSH password: root (user: root) ==="
echo "=== VPS: ssh -L 16080:localhost:6080 root@CODESPACE_HOST -p CODESPACE_PORT ==="
