#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Функция для проверки HTTP сервиса
check_http() {
    local service=$1
    local url=$2
    echo -n "Проверка $service на $url ... "
    if curl -s -f -m 5 "$url" > /dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi
}

# Функция для проверки PostgreSQL
check_postgresql() {
    local host=$1
    echo -n "Проверка PostgreSQL на $host ... "
    if PGPASSWORD=MediaWikiSecurePass2024! psql -h "$host" -U mediawiki -d mediawiki -c "\l" > /dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi
}

echo "=== Проверка Frontend серверов ==="
check_http "MediaWiki" "http://51.250.15.205/mediawiki"
check_http "MediaWiki" "http://89.169.141.43/mediawiki"

echo -e "\n=== Проверка PostgreSQL серверов ==="
check_postgresql "84.201.135.33"
check_postgresql "51.250.81.179"

echo -e "\n=== Проверка систем мониторинга ==="
check_http "Zabbix" "http://158.160.55.200/zabbix"
check_http "Grafana" "http://89.169.135.163:3000"

# Проверка состояния сервисов через Terraform
echo -e "\n=== Проверка состояния серверов через Terraform ==="
terraform show -json | jq -r '.values.root_module.resources[] | select(.type == "yandex_compute_instance") | "\(.values.name): \(.values.status)"' 