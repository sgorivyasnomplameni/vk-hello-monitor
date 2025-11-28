# VK Hello Monitor

Небольшое тестовое решение для мониторинга простого веб-приложения.

## Что делает

- поднимает Flask-приложение, которое по `/` отдаёт `Hello World!`;
- раз в N секунд проверяет его доступность HTTP-запросом;
- пишет логи работы мониторинга в файл;
- при недоступности сервиса перезапускает его через `systemd`;
- ставится одним скриптом `install.sh`.

Решение рассчитано на Linux с `systemd`.

## Структура

```text
app/app.py                # Flask-приложение (Hello World)
monitor/monitor.sh        # скрипт мониторинга и перезапуска
config/config.env         # параметры (порт, URL, интервал, путь к логам)
services/hello-app.service
services/hello-monitor.service
install.sh                # установка и настройка systemd-сервисов
requirements.txt          # зависимости Python
```

## Конфигурация

Все параметры лежат в `config/config.env`:

```bash
APP_PORT=5000                           # порт приложения
APP_URL="http://127.0.0.1:${APP_PORT}/" # URL для проверки
CHECK_INTERVAL=5                        # интервал проверки (секунд)
LOG_FILE="/var/log/hello-monitor/monitor.log"  # лог мониторинга
APP_SERVICE="hello-app.service"         # имя сервиса приложения
```

При необходимости можно изменить порт, интервал или путь к логам.

## Установка

Требуется:

- Linux с `systemd`;
- `python3`, `python3-venv`;
- `curl`.

Дальше из корня репозитория:

```bash
chmod +x install.sh
chmod +x monitor/monitor.sh
sudo ./install.sh
```

Скрипт скопирует проект в `/opt/hello-monitor`, создаст виртуальное окружение,
установит зависимости, положит unit-файлы в `/etc/systemd/system` и включит
автозапуск `hello-app.service` и `hello-monitor.service`.

## Проверка

Проверить, что сервисы поднялись:

```bash
systemctl status hello-app.service
systemctl status hello-monitor.service
```

Проверить ответ приложения:

```bash
curl http://127.0.0.1:5000/
```

Ожидаемый ответ:

```text
Hello World!
```

Проверить работу мониторинга:

1. Остановить приложение вручную:

   ```bash
   sudo systemctl stop hello-app.service
   ```

2. Через несколько секунд приложение должно быть снова в состоянии
   `active (running)`, запись о перезапуске появится в логе:

   ```bash
   sudo tail -n 20 /var/log/hello-monitor/monitor.log
   ```