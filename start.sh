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
# cloudflared tunnel - prefer named tunnel, fallback to trycloudflare
echo ">>> Starting cloudflared tunnel..."

# Try named tunnel first
NAMED_CONFIG=/home/vscode/.cloudflared/vnc-config.yml
NAMED_LOG=/tmp/cloudflared-named.log

if [ -f "$NAMED_CONFIG" ]; then
    echo "Starting named tunnel (vnc.jimmyelsa.com)..."
    nohup cloudflared tunnel --config "$NAMED_CONFIG" run > "$NAMED_LOG" 2>&1 &
    echo "Named tunnel started (check /tmp/cloudflared-named.log)"
fi

# Also start trycloudflare as fallback with URL capture
nohup bash -c '
  cloudflared tunnel --url http://localhost:6080 --loglevel info 2>&1 | \
  while IFS= read -r line; do
    echo "$line"
    # Extract trycloudflare URL
    url=$(echo "$line" | grep -oP "https://[a-z0-9-]+\.trycloudflare\.com" | head -1)
    if [ -n "$url" ]; then
      echo "$url" > /workspaces/chrome-vnc/tunnel_url.txt
      echo "TUNNEL URL: $url"
    fi
  done
' &
sleep 5
echo "Tunnel starting..."
cat /workspaces/chrome-vnc/tunnel_url.txt 2>/dev/null || echo "waiting for URL..."

echo "=== SSH password: root (user: root) ==="
echo "=== VPS: ssh -L 16080:localhost:6080 root@CODESPACE_HOST -p CODESPACE_PORT ==="
