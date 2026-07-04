#!/bin/bash
set -e

echo "=== Starting Chrome Remote Desktop ==="

# Kill any existing instances
pkill -f Xvfb 2>/dev/null || true
pkill -f x11vnc 2>/dev/null || true
pkill -f fluxbox 2>/dev/null || true
pkill -f websockify 2>/dev/null || true
sleep 1

# Start virtual display
export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 &
sleep 1

# Start window manager
fluxbox &
sleep 1

# Start VNC server
x11vnc -display :99 -forever -nopw -quiet -rfbport 5900 &
sleep 1

# Start noVNC (web interface on port 6080)
if [ -f /opt/noVNC/utils/novnc_proxy ]; then
  /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &
elif [ -f /usr/share/novnc/utils/novnc_proxy ]; then
  /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &
else
  python3 -m websockify --web /usr/share/novnc 6080 localhost:5900 &
fi
sleep 1

# Open Chrome on startup (it'll show in noVNC)
google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage \
  --start-maximized --window-size=1920,1080 \
  https://claude.ai &

echo ""
echo "============================================"
echo "✅ Chrome Remote Desktop is running!"
echo "============================================"
echo ""
echo "Open the 'Ports' tab (Ctrl+Shift+P → 'Ports: Focus on Ports View')"
echo "Find port 6080, click the globe icon to open in browser"
echo ""
echo "You'll see a web-based VNC viewer with Chrome"
echo "Type 'claude.ai' in the address bar to start"
echo ""
