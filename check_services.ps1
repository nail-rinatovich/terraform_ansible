# Функция для проверки HTTP сервиса
function Check-HttpService {
    param(
        [string]$Service,
        [string]$Url
    )
    Write-Host "Проверка $Service на $Url ... " -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 5 -ErrorAction Stop
        Write-Host "OK" -ForegroundColor Green
    } catch {
        Write-Host "FAIL" -ForegroundColor Red
    }
}

# Проверка состояния через Terraform
Write-Host "`n=== Проверка состояния серверов через Terraform ==="
cd C:\Users\admin\mediawiki-terraform
$tfState = & 'C:\Users\admin\Downloads\terraform_1.11.4_windows_amd64\terraform.exe' show
if ($tfState -match "running") {
    Write-Host "Все серверы в состоянии running" -ForegroundColor Green
} else {
    Write-Host "Возможны проблемы с серверами" -ForegroundColor Red
}

Write-Host "`n=== Проверка Frontend серверов ==="
Check-HttpService -Service "MediaWiki" -Url "http://51.250.15.205/mediawiki"
Check-HttpService -Service "MediaWiki" -Url "http://89.169.141.43/mediawiki"

Write-Host "`n=== Проверка систем мониторинга ==="
Check-HttpService -Service "Zabbix" -Url "http://158.160.55.200/zabbix"
Check-HttpService -Service "Grafana" -Url "http://89.169.135.163:3000"

# Вывод IP адресов для SSH проверки
Write-Host "`n=== Информация для ручной проверки PostgreSQL ==="
Write-Host "PostgreSQL Master: 84.201.135.33"
Write-Host "PostgreSQL Replica: 51.250.81.179"
Write-Host "Команда для проверки: psql -h HOST -U mediawiki -d mediawiki -W" 