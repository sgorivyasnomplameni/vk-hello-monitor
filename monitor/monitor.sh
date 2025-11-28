#!/usr/bin/env bash
# monitor.sh — мониторинг Flask-приложения.
# Проверяет доступность, логирует и перезапускает сервис в случае сбоя.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/config.env"

# Загружаем параметры
# shellcheck disable=SC1090
source "${CONFIG_FILE}"

# Создаём каталог для логов
mkdir -p "$(dirname "${LOG_FILE}")"
touch "${LOG_FILE}"

log() {
    local level="$1"
    local msg="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [${level}] ${msg}" >> "${LOG_FILE}"
}

log "INFO" "Monitor started. Checking ${APP_URL} every ${CHECK_INTERVAL}s."

while true; do
    # Проверяем доступность приложения
    http_code="$(curl -s -o /dev/null -w '%{http_code}' "${APP_URL}" || echo 000)"

    if [[ "${http_code}" == "200" ]]; then
        log "INFO" "Application is UP (HTTP 200)."
    else
        log "ERROR" "Application is DOWN (HTTP ${http_code}). Restarting service ${APP_SERVICE}..."

        if systemctl restart "${APP_SERVICE}" >> "${LOG_FILE}" 2>&1; then
            log "INFO" "Restart successful."
        else
            log "ERROR" "Failed to restart service."
        fi
    fi

    sleep "${CHECK_INTERVAL}"
done