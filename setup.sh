#!/bin/bash
exec > /tmp/setup.log 2>&1
set -e

echo "=== Setup starting at $(date) ==="

apt-get update -qq
apt-get install -y -qq wget curl gnupg ca-certificates openssh-client

# Chrome
wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update -qq
apt-get install -y -qq google-chrome-stable 2>&1 | tail -1
echo "Chrome: $(google-chrome --version 2>&1)"

# VNC
apt-get install -y -qq xvfb x11vnc fluxbox 2>&1 | tail -1

# noVNC from source
apt-get install -y -qq python3 python3-websockify git 2>&1 | tail -1
cd /opt
git clone --depth=1 https://github.com/novnc/noVNC.git 2>/dev/null || echo "noVNC exists"
cd /opt/noVNC/utils && git clone --depth=1 https://github.com/novnc/websockify.git 2>/dev/null || echo "websockify exists"

# SSH key for reverse tunnel to VPS
mkdir -p /root/.ssh
cat >> /root/.ssh/authorized_keys << 'KEYEOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG8Vl/ynGjb5aKcMoQl1vsVD9345OFFvFkn7PdJ1LJbl ubuntu@osaka-arm
KEYEOF

# VPS host key
cat >> /root/.ssh/known_hosts << 'HOSTEOF'
129.146.63.70 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQ/wDSXRjA3/KF8IJBwcT5FaA2DrmyH1g/dOSI+omCQ
HOSTEOF

echo ">>> Setup complete at $(date)"
