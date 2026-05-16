#!/bin/bash

# Install modelrelay globally
sudo npm install modelrelay -g --prefix /usr/local/lib/modelrelay
sudo ln -sf /usr/local/lib/modelrelay/bin/modelrelay /usr/local/bin/modelrelay
sudo npm cache clean --force

echo "[post-create-cmd.sh] Checking modelrelay..."
if command -v modelrelay &>/dev/null; then
  if pgrep -f modelrelay > /dev/null; then
    echo "[post-create-cmd.sh] modelrelay is already running, skipping"
  else
    echo "[post-create-cmd.sh] Starting modelrelay in the background..."
    setsid /usr/local/bin/modelrelay >> /tmp/modelrelay.log 2>&1 &
  fi
else
  echo "[post-create-cmd.sh] modelrelay not found, skipping start"
fi

# Install Cline with default configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[post-create-cmd.sh] Installing Cline with default configuration..."
mkdir -p "$HOME/.cline/data"
cp "${SCRIPT_DIR}/globalState.json" "$HOME/.cline/data/globalState.json"
cp "${SCRIPT_DIR}/secrets.json" "$HOME/.cline/data/secrets.json"
bash -c 'code --force --install-extension saoudrizwan.claude-dev'
npm install -g cline
