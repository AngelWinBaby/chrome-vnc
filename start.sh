#!/bin/bash
exec > /tmp/start.log 2>&1
echo "=== Start at $(date) ==="

export DISPLAY=:99
export HOME=/root

# Kill existing
pkill -f Xvfb 2>/dev/null || true
pkill -f x11vnc 2>/dev/null || true  
pkill -f fluxbox 2>/dev/null || true
sleep 1

# Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 -ac &
sleep 2

# Window manager
fluxbox &
sleep 1

# VNC
x11vnc -display :99 -forever -nopw -quiet -rfbport 5900 -shared &
sleep 2

# noVNC
cd /opt/noVNC && { ./utils/novnc_proxy --vnc localhost:5900 --listen 6080 & }
sleep 2

echo "=== Services started ==="
ss -tlnp | grep -E '5900|6080'

# Create reverse tunnel to VPS (so user can access via claude.jimmyelsa.com)
# The VPS will forward localhost:16080 -> codespace:6080
ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=30 \
  -N -R 16080:localhost:6080 ubuntu@129.146.63.70 &
echo "Reverse tunnel started"
