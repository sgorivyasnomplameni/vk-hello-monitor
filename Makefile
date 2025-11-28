APP_DIR      := /opt/hello-monitor
APP_SERVICE  := hello-app.service
MON_SERVICE  := hello-monitor.service
LOG_FILE     := /var/log/hello-monitor/monitor.log
APP_URL      := http://127.0.0.1:5000/

.PHONY: help install reinstall uninstall start stop restart status logs test

help:
	@echo "Targets:"
	@echo "  make install    - установить/обновить систему мониторинга"
	@echo "  make reinstall  - переустановить (uninstall + install)"
	@echo "  make uninstall  - выключить сервисы и удалить их из systemd"
	@echo "  make start      - запустить оба сервиса"
	@echo "  make stop       - остановить оба сервиса"
	@echo "  make restart    - перезапустить оба сервиса"
	@echo "  make status     - показать статус сервисов"
	@echo "  make logs       - показать последние строки логов мониторинга"
	@echo "  make test       - проверить, что приложение отдаёт Hello World"

install:
	sudo chmod +x install.sh monitor/monitor.sh
	sudo ./install.sh

reinstall: uninstall install

uninstall:
	- sudo systemctl stop $(APP_SERVICE) $(MON_SERVICE)
	- sudo systemctl disable $(APP_SERVICE) $(MON_SERVICE)
	- sudo rm -f /etc/systemd/system/$(APP_SERVICE)
	- sudo rm -f /etc/systemd/system/$(MON_SERVICE)
	- sudo systemctl daemon-reload

start:
	sudo systemctl start $(APP_SERVICE) $(MON_SERVICE)

stop:
	sudo systemctl stop $(APP_SERVICE) $(MON_SERVICE)

restart:
	sudo systemctl restart $(APP_SERVICE) $(MON_SERVICE)

status:
	sudo systemctl status $(APP_SERVICE)
	@echo
	sudo systemctl status $(MON_SERVICE)

logs:
	sudo tail -n 30 $(LOG_FILE)

test:
	@echo "GET $(APP_URL)"
	@curl -v $(APP_URL) || true