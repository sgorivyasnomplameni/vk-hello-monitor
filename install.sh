#!/usr/bin/env bash
# install.sh — установка/обновление hello-monitor

set -euo pipefail

APP_DIR="/opt/hello-monitor"
SYSTEMD_DIR="/etc/systemd/system"

APP_SERVICE_NAME="hello-app.service"
MONITOR_SERVICE_NAME="hello-monitor.service"

echo "[*] Starting installation..."

# Проверяем, что скрипт запущен от root
if [[ "$EUID" -ne 0 ]]; then
  echo "[!] Please run this script as root (sudo ./install.sh)"
  exit 1
fi

echo "[*] Creating application directory at ${APP_DIR}..."
mkdir -p "${APP_DIR}"

echo "[*] Copying application files..."
# Копируем основные части проекта
cp -r app "${APP_DIR}/"
cp -r monitor "${APP_DIR}/"
cp -r config "${APP_DIR}/"

# Если есть requirements.txt — копируем
if [[ -f "requirements.txt" ]]; then
  cp requirements.txt "${APP_DIR}/"
fi

echo "[*] Creating log directory..."
mkdir -p /var/log/hello-monitor

echo "[*] Installing Python dependencies (if requirements.txt exists)..."
if command -v python3 >/dev/null 2>&1; then
  if [[ -f "${APP_DIR}/requirements.txt" ]]; then
    python3 -m pip install --upgrade pip >/dev/null 2>&1 || true
    python3 -m pip install -r "${APP_DIR}/requirements.txt"
  else
    echo "[!] requirements.txt not found, skipping pip install."
  fi
else
  echo "[!] python3 not found. Please install Python 3 manually."
fi

echo "[*] Installing systemd unit files..."
cp services/hello-app.service "${SYSTEMD_DIR}/${APP_SERVICE_NAME}"
cp services/hello-monitor.service "${SYSTEMD_DIR}/${MONITOR_SERVICE_NAME}"

echo "[*] Reloading systemd daemon..."
systemctl daemon-reload

echo "[*] Enabling services..."
systemctl enable "${APP_SERVICE_NAME}"
systemctl enable "${MONITOR_SERVICE_NAME}"

echo "[*] Restarting services..."
systemctl restart "${APP_SERVICE_NAME}"
systemctl restart "${MONITOR_SERVICE_NAME}"

echo "[✓] Installation completed successfully."
echo "[i] App service:    systemctl status ${APP_SERVICE_NAME}"
echo "[i] Monitor service: systemctl status ${MONITOR_SERVICE_NAME}"