#!/bin/bash
set -e

# Install MariaDB
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server

# Siapkan direktori log
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
chmod 750 /var/log/mysql

# Konfigurasi Master
cat > /etc/mysql/mariadb.conf.d/60-replication.cnf <<'EOF'
[mysqld]
server-id = 17
log_bin = /var/log/mysql/mariadb-bin
binlog_format = ROW
binlog_do_db = db_shibuya_k64
bind-address = 0.0.0.0
EOF

# Restart MariaDB
service mariadb restart

# Tunggu service siap
until mariadb -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

# Database, tabel, dan akun
mariadb <<'SQL'
CREATE DATABASE IF NOT EXISTS db_shibuya_k64;

CREATE TABLE IF NOT EXISTS db_shibuya_k64.request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(45) NOT NULL,
    request_path VARCHAR(255) NOT NULL,
    status_code INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER IF NOT EXISTS 'repl'@'192.243.4.18'
IDENTIFIED BY 'K64Repl2026!';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.243.4.18';

CREATE USER IF NOT EXISTS 'appuser'@'192.243.4.%'
IDENTIFIED BY 'K64App2026!';

GRANT ALL PRIVILEGES ON db_shibuya_k64.* TO 'appuser'@'192.243.4.%';

FLUSH PRIVILEGES;
SQL

echo "=== Status Master ==="
mariadb -e "SHOW VARIABLES LIKE 'server_id';"
mariadb -e "SHOW VARIABLES LIKE 'log_bin';"
mariadb -e "SHOW MASTER STATUS\G"
echo "Konfigurasi Master selesai."