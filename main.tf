// Frontend instances
resource "yandex_compute_instance" "frontend_1" {
  name        = "mediawiki-frontend-1"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.instance_resources.cores
    memory        = var.instance_resources.memory
    core_fraction = var.instance_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size = var.disk_sizes["frontend"]
      type = "network-ssd"
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    ip_address = "10.128.0.10"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
    user-data = <<-EOT
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y nginx php8.1 php8.1-fpm php8.1-pgsql php8.1-xml php8.1-intl php8.1-gd php8.1-mbstring php8.1-curl php8.1-apcu

cd /var/www/html
wget https://releases.wikimedia.org/mediawiki/1.42/mediawiki-1.42.1.tar.gz
tar xvzf mediawiki-1.42.1.tar.gz
mv mediawiki-1.42.1 mediawiki
chown -R www-data:www-data mediawiki

cat > /var/www/html/mediawiki/LocalSettings.php <<'EOF'
<?php
$wgSitename = "MediaWiki";
$wgMetaNamespace = "MediaWiki";
$wgDBtype = "postgres";
$wgDBserver = "10.128.0.20";
$wgDBname = "mediawiki";
$wgDBuser = "mediawiki";
$wgDBpassword = "${var.db_password}";
$wgServer = "http://LOAD_BALANCER_IP";
$wgCanonicalServer = "http://LOAD_BALANCER_IP";
$wgScriptPath = "/mediawiki";
$wgArticlePath = "/mediawiki/$1";
$wgUsePathInfo = true;
$wgMainCacheType = CACHE_ACCEL;
$wgMemCachedServers = [];
$wgShowExceptionDetails = true;
$wgShowDBErrorBacktrace = true;
$wgShowSQLErrors = true;
$wgSecretKey = "$(openssl rand -base64 32)";
$wgUpgradeKey = "$(openssl rand -base64 32)";
EOF

cat > /etc/nginx/sites-available/mediawiki <<'EOF'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html/mediawiki;
    index index.php;

    location = / {
        return 301 /mediawiki;
    }

    location /mediawiki {
        try_files $uri $uri/ @mediawiki;
    }

    location @mediawiki {
        rewrite ^/mediawiki/(.*)$ /mediawiki/index.php?title=$1&$args last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\. {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/mediawiki /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx php8.1-fpm

# Установка Zabbix агента
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt-get update
apt-get install -y zabbix-agent

# Настройка Zabbix агента
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=10.128.0.31
ServerActive=10.128.0.31
Hostname=mediawiki-frontend-1
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

systemctl restart zabbix-agent
systemctl enable zabbix-agent

# Установка прав доступа
chown -R www-data:www-data /var/www/html/mediawiki
chmod -R 755 /var/www/html/mediawiki
EOT
  }
}

resource "yandex_compute_instance" "frontend_2" {
  name        = "mediawiki-frontend-2"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.instance_resources.cores
    memory        = var.instance_resources.memory
    core_fraction = var.instance_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size = var.disk_sizes["frontend"]
      type = "network-ssd"
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    ip_address = "10.128.0.11"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
    user-data = <<-EOT
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y nginx php8.1 php8.1-fpm php8.1-pgsql php8.1-xml php8.1-intl php8.1-gd php8.1-mbstring php8.1-curl php8.1-apcu

cd /var/www/html
wget https://releases.wikimedia.org/mediawiki/1.42/mediawiki-1.42.1.tar.gz
tar xvzf mediawiki-1.42.1.tar.gz
mv mediawiki-1.42.1 mediawiki
chown -R www-data:www-data mediawiki

cat > /var/www/html/mediawiki/LocalSettings.php <<'EOF'
<?php
$wgSitename = "MediaWiki";
$wgMetaNamespace = "MediaWiki";
$wgDBtype = "postgres";
$wgDBserver = "10.128.0.20";
$wgDBname = "mediawiki";
$wgDBuser = "mediawiki";
$wgDBpassword = "${var.db_password}";
$wgServer = "http://LOAD_BALANCER_IP";
$wgCanonicalServer = "http://LOAD_BALANCER_IP";
$wgScriptPath = "/mediawiki";
$wgArticlePath = "/mediawiki/$1";
$wgUsePathInfo = true;
$wgMainCacheType = CACHE_ACCEL;
$wgMemCachedServers = [];
$wgShowExceptionDetails = true;
$wgShowDBErrorBacktrace = true;
$wgShowSQLErrors = true;
$wgSecretKey = "$(openssl rand -base64 32)";
$wgUpgradeKey = "$(openssl rand -base64 32)";
EOF

cat > /etc/nginx/sites-available/mediawiki <<'EOF'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html/mediawiki;
    index index.php;

    location = / {
        return 301 /mediawiki;
    }

    location /mediawiki {
        try_files $uri $uri/ @mediawiki;
    }

    location @mediawiki {
        rewrite ^/mediawiki/(.*)$ /mediawiki/index.php?title=$1&$args last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\. {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/mediawiki /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx php8.1-fpm

# Установка Zabbix агента
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt-get update
apt-get install -y zabbix-agent

# Настройка Zabbix агента
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=10.128.0.31
ServerActive=10.128.0.31
Hostname=mediawiki-frontend-2
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

systemctl restart zabbix-agent
systemctl enable zabbix-agent

# Установка прав доступа
chown -R www-data:www-data /var/www/html/mediawiki
chmod -R 755 /var/www/html/mediawiki
EOT
  }
}

resource "yandex_compute_instance" "postgresql_master" {
  name        = "mediawiki-postgresql-master"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.instance_resources.cores
    memory        = var.instance_resources.memory
    core_fraction = var.instance_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size = var.disk_sizes["database"]
      type = "network-ssd"
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    ip_address = "10.128.0.20"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
    user-data = <<-EOT
#!/bin/bash
apt-get update
apt-get install -y postgresql postgresql-contrib
systemctl enable postgresql
systemctl start postgresql

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
echo "host    all             all             10.128.0.0/24           md5" >> /etc/postgresql/12/main/pg_hba.conf
systemctl restart postgresql

sudo -u postgres psql -c "CREATE DATABASE mediawiki;"
sudo -u postgres psql -c "CREATE USER mediawiki WITH ENCRYPTED PASSWORD '${var.db_password}';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mediawiki TO mediawiki;"

sudo -u postgres psql -c "CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD '${var.db_password}';"
echo "host    replication     replicator      10.128.0.0/24           md5" >> /etc/postgresql/12/main/pg_hba.conf
systemctl restart postgresql

# Установка Zabbix агента
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt-get update
apt-get install -y zabbix-agent

# Настройка Zabbix агента
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=10.128.0.31
ServerActive=10.128.0.31
Hostname=mediawiki-postgresql-master
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

# Добавление пользовательских параметров для мониторинга PostgreSQL
cat > /etc/zabbix/zabbix_agentd.d/postgresql.conf <<EOF
UserParameter=pgsql.ping,/usr/lib/zabbix/externalscripts/check_postgresql.sh --host=localhost --dbname=mediawiki --username=mediawiki --password=${var.db_password} --query=ping
UserParameter=pgsql.uptime,/usr/lib/zabbix/externalscripts/check_postgresql.sh --host=localhost --dbname=mediawiki --username=mediawiki --password=${var.db_password} --query=uptime
UserParameter=pgsql.connections,/usr/lib/zabbix/externalscripts/check_postgresql.sh --host=localhost --dbname=mediawiki --username=mediawiki --password=${var.db_password} --query=connections
EOF

systemctl restart zabbix-agent
systemctl enable zabbix-agent
EOT
  }
}

resource "yandex_compute_instance" "postgresql_replica" {
  name        = "mediawiki-postgresql-replica"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.instance_resources.cores
    memory        = var.instance_resources.memory
    core_fraction = var.instance_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size = var.disk_sizes["database"]
      type = "network-ssd"
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    ip_address = "10.128.0.21"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
    user-data = <<-EOT
#!/bin/bash
apt-get update
apt-get install -y postgresql postgresql-contrib
systemctl stop postgresql

rm -rf /var/lib/postgresql/12/main
sudo -u postgres pg_basebackup -h 10.128.0.20 -U replicator -D /var/lib/postgresql/12/main -P -R

echo "primary_conninfo = 'host=10.128.0.20 port=5432 user=replicator password=${var.db_password}'" >> /etc/postgresql/12/main/postgresql.conf
echo "hot_standby = on" >> /etc/postgresql/12/main/postgresql.conf

systemctl start postgresql

# Установка Zabbix агента
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt-get update
apt-get install -y zabbix-agent

# Настройка Zabbix агента
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=10.128.0.31
ServerActive=10.128.0.31
Hostname=mediawiki-postgresql-replica
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

# Добавление пользовательских параметров для мониторинга PostgreSQL
cat > /etc/zabbix/zabbix_agentd.d/postgresql.conf <<EOF
UserParameter=pgsql.ping,/usr/lib/zabbix/externalscripts/check_postgresql.sh --host=localhost --dbname=mediawiki --username=mediawiki --password=${var.db_password} --query=ping
UserParameter=pgsql.uptime,/usr/lib/zabbix/externalscripts/check_postgresql.sh --host=localhost --dbname=mediawiki --username=mediawiki --password=${var.db_password} --query=uptime
UserParameter=pgsql.replication_lag,/usr/lib/zabbix/externalscripts/check_postgresql.sh --host=localhost --dbname=mediawiki --username=mediawiki --password=${var.db_password} --query=replication_lag
EOF

systemctl restart zabbix-agent
systemctl enable zabbix-agent
EOT
  }
}

resource "yandex_compute_instance" "monitoring" {
  name        = "mediawiki-monitoring"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.instance_resources.cores
    memory        = var.instance_resources.memory
    core_fraction = var.instance_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size = var.disk_sizes["monitoring"]
      type = "network-ssd"
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    ip_address = "10.128.0.30"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
    user-data = <<-EOT
#!/bin/bash
apt-get update
apt-get install -y prometheus prometheus-node-exporter grafana

cat > /etc/prometheus/prometheus.yml <<'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['10.128.0.10:9100', '10.128.0.11:9100', '10.128.0.20:9100', '10.128.0.21:9100']
EOF

systemctl restart prometheus
systemctl restart grafana-server
EOT
  }
}

resource "yandex_lb_network_load_balancer" "frontend_balancer" {
  name = "frontend-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.frontend_group.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/mediawiki"
      }
    }
  }
}

resource "yandex_lb_target_group" "frontend_group" {
  name = "mediawiki-frontend-group"

  target {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    address   = "10.128.0.10"
  }

  target {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    address   = "10.128.0.11"
  }
}

// Zabbix Server
resource "yandex_compute_instance" "zabbix_server" {
  name        = "mediawiki-zabbix"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.instance_resources.cores
    memory        = var.instance_resources.memory
    core_fraction = var.instance_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size = var.disk_sizes["zabbix"]
      type = "network-ssd"
      image_id = "fd8emvfmfoaordspe1jr" # Ubuntu 20.04 LTS
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.existing_subnet.id
    ip_address = "10.128.0.31"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
    user-data = <<-EOT
#!/bin/bash
# Обновление системы
apt-get update
apt-get upgrade -y

# Установка необходимых пакетов
apt-get install -y apache2 mysql-server php php-mysql php-gd php-ldap php-xml php-mbstring

# Добавление репозитория Zabbix
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt-get update

# Установка Zabbix сервера
apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Создание базы данных для Zabbix
mysql -uroot <<EOF
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by '${var.db_password}';
grant all privileges on zabbix.* to zabbix@localhost;
EOF

# Импорт начальной схемы и данных
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p${var.db_password} zabbix

# Настройка конфигурации Zabbix
sed -i 's/# DBPassword=/DBPassword=${var.db_password}/' /etc/zabbix/zabbix_server.conf

# Настройка PHP для веб-интерфейса
sed -i 's/;date.timezone =/date.timezone = Europe\/Moscow/' /etc/php/7.4/apache2/php.ini

# Перезапуск сервисов
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

# Настройка агентов на всех серверах
cat > /etc/zabbix/zabbix_server.conf.d/mediawiki_hosts.conf <<EOF
# Frontend servers
ServerActive=10.128.0.10,10.128.0.11
# Database servers
ServerActive=10.128.0.20,10.128.0.21
# Monitoring server
ServerActive=10.128.0.30
EOF

systemctl restart zabbix-server
EOT
  }
}

data "yandex_vpc_network" "existing_network" {
  name = var.network_name
}

data "yandex_vpc_subnet" "existing_subnet" {
  name = var.subnet_name
} 