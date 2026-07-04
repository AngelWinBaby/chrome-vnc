#!/bin/bash
set -e

echo "=== Setting up Chrome Remote Desktop ==="

# 1. Install Chrome
echo ">>> Installing Google Chrome..."
wget -q -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get update -qq
sudo apt-get install -y -qq ./chrome.deb 2>/dev/null || {
  # Fallback: install deps then chrome
  sudo apt-get install -y -qq wget curl gnupg
  wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update -qq
  sudo apt-get install -y -qq google-chrome-stable
}
rm -f chrome.deb
echo ">>> Chrome installed: $(google-chrome --version)"

# 2. Install VNC + noVNC + Window Manager
echo ">>> Installing VNC and noVNC..."
sudo apt-get install -y -qq \
  xvfb \
  x11vnc \
  fluxbox \
  novnc \
  net-tools \
  x11-utils

# 3. Install noVNC if not already (the package might be different)
if ! command -v /usr/share/novnc/utils/novnc_proxy &> /dev/null; then
  echo ">>> Installing noVNC from source..."
  git clone --depth=1 https://github.com/novnc/noVNC.git /opt/noVNC
  git clone --depth=1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify
fi

# 4. Create VNC password (no password - accessible via forwarded port only)
mkdir -p ~/.vnc
x11vnc -storepasswd "" ~/.vnc/passwd 2>/dev/null || true

echo ""
echo "✅ Setup complete!"
echo "Run 'bash /workspace/start.sh' to start."
