# Hello Monitor

Проект для мониторинга простого веб-приложения с автоматическим перезапуском.
Используются Python (Flask), Bash и systemd.

## Что делает

* запускает Flask-приложение, отдающее `Hello World!` на корневом маршруте;
* периодически проверяет доступность приложения по HTTP;
* пишет результаты проверок в лог-файл;
* при недоступности перезапускает сервис через systemd;
* устанавливается одним скриптом.

Проект рассчитан на Linux с systemd.

## Структура проекта
```
app/
app.py — Flask-приложение

monitor/
monitor.sh — Bash-скрипт мониторинга

config/
config.env — параметры приложения и мониторинга

services/
hello-app.service — unit-файл systemd для приложения
hello-monitor.service — unit-файл systemd для мониторинга

install.sh — установка и настройка сервисов
requirements.txt — зависимости Python
Makefile — вспомогательные команды
README.md — описание решения
```
## Конфигурация

Параметры находятся в файле config/config.env:
```
APP_PORT=5000
APP_URL="http://127.0.0.1:${APP_PORT}/"
CHECK_INTERVAL=5
LOG_FILE="/var/log/hello-monitor/monitor.log"
APP_SERVICE="hello-app.service"
```
Здесь можно изменить порт, интервал проверки, URL и путь к логам.

## Как работает

* `app.py` — это минимальное Flask-приложение, которое слушает HTTP-запросы и возвращает строку `Hello World!` на корневом маршруте.
* `hello-app.service` — это unit-файл для systemd, который управляет запуском Flask-приложения как сервиса, чтобы приложение перезапускалось автоматически при сбоях. Мы использовали systemd, потому что это стандартный инструмент для управления сервисами в Linux, который обеспечит автоматический перезапуск приложения в случае его остановки.
* `monitor.sh` делает запрос к APP_URL, логирует результат и при недоступности вызывает `systemctl restart`;
* `hello-monitor.service` запускает мониторинг как отдельный сервис systemd;
* `install.sh` копирует проект в /opt/hello-monitor, создаёт virtualenv, устанавливает зависимости и активирует оба сервиса;
* `Makefile` упрощает установку, проверку статуса, просмотр логов и тестирование.

## Установка

Требуется:

* Linux с systemd
* python3 + python3-venv
* curl

Установка выполняется из корня проекта:

```
chmod +x install.sh
chmod +x monitor/monitor.sh
sudo ./install.sh
```

Скрипт создаст каталог `/opt/hello-monitor`, виртуальное окружение, установит зависимости и включит сервисы.

Если у вас не установлен Python 3, выполните:
```
sudo apt-get install python3 python3-venv
Если curl не установлен:
sudo apt-get install curl
```

## Проверка

Проверка работы сервисов:

```
systemctl status hello-app.service
systemctl status hello-monitor.service
```

Ответ приложения:

```
curl http://127.0.0.1:5000/
```

Ожидается:

```
Hello World!
```

Проверка работы мониторинга:

```
sudo systemctl stop hello-app.service
sudo tail -n 20 /var/log/hello-monitor/monitor.log
```

## Команды Makefile

```
make install      — установка
make status       — статус сервисов и HTTP-проверка
make logs         — последние строки логов
make test         — тестовый HTTP-запрос
make uninstall    — отключение сервисов и удаление unit-файлов
```
