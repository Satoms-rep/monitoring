Инструкция по развертыванию мониторинга в Ubuntu контейнере

1. Подготовка служб
 - Запуск скрипта на локальном ПК
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\install-exporters.ps1
 - добавьте DNS имя и порт

2. Сборка и запуск
docker-compose up -d
docker-compose down

3. Проверка работы
- Grafana: http://server-ip:3000 
  * логин: admin 
  * пароль: admin
- Prometheus: http://server-ip:9090

4. Grafana настройки
- Добавить адрес prometheus: http://prometheus:9090
- Добавить дашборды: 10467, 14451, 14510, 14694, 10826, 10795

### [main.yml](file:///c%3A/Dev/monitoring/.github/workflows/main.yml)

Добавьте workflow для автоматического деплоя через SSH на сервер Ubuntu.  
Файлы копируются через `scp` или делается `git clone`/`git pull` на сервере.  
В вашем случае проще делать `git pull` на сервере, чтобы всегда были актуальные файлы.

**Пример workflow:**

````yaml
name: Deploy to Ubuntu Server

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.SSH_KEY }}
          ssh-passphrase: ${{ secrets.SSH_PASSPHRASE }}

      - name: Deploy via SSH
        env:
          HOST: ${{ secrets.HOST }}
          USER: ${{ secrets.USER }}
        run: |
          ssh -o StrictHostKeyChecking=no $USER@$HOST '
            set -e
            if [ ! -d ~/monitoring ]; then
              git clone git@github.com:Satoms-rep/monitoring.git ~/monitoring
            else
              cd ~/monitoring
              git pull
            fi
            cd ~/monitoring
            docker-compose pull
            docker-compose up -d
          '


