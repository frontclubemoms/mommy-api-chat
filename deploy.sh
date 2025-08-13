#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/home/ubuntu/mommy-api-chat"
REPO_URL="https://github.com/frontclubemoms/mommy-api-chat.git"
PM2_NAME="mommy-api-chat"

# Ensure app dir
sudo mkdir -p "$APP_DIR"
sudo chown -R "$USER":"$USER" "$APP_DIR"

cd "$APP_DIR"

if [ ! -d .git ]; then
  echo "[deploy] Cloning repo..."
  git clone "$REPO_URL" "$APP_DIR"
else
  echo "[deploy] Fetching latest..."
  git fetch --all
fi

echo "[deploy] Reset to origin/main"
git reset --hard origin/main || (git checkout main && git reset --hard origin/main)

echo "[deploy] Install deps"
npm ci || npm install

echo "[deploy] Build"
npm run build

echo "[deploy] Start/reload with PM2"
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  pm2 reload "$PM2_NAME"
else
  pm2 start dist/main.js --name "$PM2_NAME"
fi

pm2 save
echo "[deploy] Done"
