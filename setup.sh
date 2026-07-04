#!/bin/bash
set -e
exec > /tmp/setup.log 2>&1

echo "=== Setup starting at $(date) ==="

# Install Chrome
echo ">>> Installing Google Chrome..."
apt-get update -qq
apt-get install -y -qq wget curl gnupg ca-certificates
wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update -qq
apt-get install -y -qq google-chrome-stable 2>&1 | tail -3
echo "Chrome: $(google-chrome --version 2>&1)"

# Install VNC + noVNC
echo ">>> Installing VNC..."
apt-get install -y -qq xvfb x11vnc fluxbox 2>&1 | tail -3

# Install noVNC from source
echo ">>> Installing noVNC..."
apt-get install -y -qq python3 python3-websockify git 2>&1 | tail -3
cd /opt
git clone --depth=1 https://github.com/novnc/noVNC.git 2>/dev/null || echo "noVNC already exists"
git clone --depth=1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify 2>/dev/null || echo "websockify exists"

echo ">>> Setup complete at $(date)"
