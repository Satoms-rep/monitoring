Инструкция по развертыванию мониторинга в Ubuntu контейнере

1. Подготовка файлов
Убедиться в наличии файлов:
- Dockerfile
- docker-compose.yml
- prometheus.yml

2. Конфигурация
В prometheus.yml изменить:
- IP адреса целевых серверов:
  * windows_exporter: 'xxx.xxx.xxx.xxx:9182'
  * blackbox: 'xxx.xxx.xxx.xxx:9115'

3. Сборка и запуск
- Собрать образ:
  docker build -t monitoring-ubuntu .
- Запустить контейнер:
  docker run -d --name monitoring-stack --privileged \
    -p 3000:3000 -p 9090:9090 monitoring-ubuntu

4. Проверка работы
- Grafana: http://server-ip:3000 
  * логин: admin 
  * пароль: admin
- Prometheus: http://server-ip:9090

5. Управление контейнером
- Просмотр логов: docker logs monitoring-stack
- Остановка: docker stop monitoring-stack
- Перезапуск: docker restart monitoring-stack
- Удаление: docker rm -f monitoring-stack

6. Grafana настройки
- Добавить адрес prometheus: http://prometheus:9090
- Добавить дашборды: 10467, 14451, 14510, 14694, 10826, 10795

Set-ExecutionPolicy Bypass -Scope Process -Force
.\install-exporters.ps1

---NEW---
docker-compose up -d
docker-compose down