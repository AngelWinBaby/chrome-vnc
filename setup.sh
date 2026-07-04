#!/bin/bash
exec > /tmp/setup.log 2>&1
set -e

echo "=== Setup $(date) ==="
apt-get update -qq
apt-get install -y -qq wget curl gnupg ca-certificates openssh-server openssh-client

# SSH server
echo ">>> SSH server..."
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
echo "root:root" | chpasswd
mkdir -p /run/sshd
/usr/sbin/sshd
echo "SSH server started"

# Chrome
wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update -qq
apt-get install -y -qq google-chrome-stable 2>&1 | tail -1
echo "Chrome: $(google-chrome --version)"

# VNC + noVNC
apt-get install -y -qq xvfb x11vnc fluxbox 2>&1 | tail -1
apt-get install -y -qq python3 python3-websockify git 2>&1 | tail -1
cd /opt && git clone --depth=1 https://github.com/novnc/noVNC.git 2>/dev/null || echo "exists"
cd /opt/noVNC/utils && git clone --depth=1 https://github.com/novnc/websockify.git 2>/dev/null || echo "exists"

# cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb 2>/dev/null || { apt-get install -y -qq -f; dpkg -i cloudflared-linux-amd64.deb; }
echo "cloudflared: $(cloudflared --version)"

echo "Setup done"
