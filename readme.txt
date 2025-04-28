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
