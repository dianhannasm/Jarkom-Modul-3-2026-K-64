#!/bin/bash
set -e

# Install MariaDB
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server

# Siapkan direktori log
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
chmod 750 /var/log/mysql

# Konfigurasi Slave
cat > /etc/mysql/mariadb.conf.d/60-replication.cnf <<'EOF'
[mysqld]
server-id = 18
relay-log = /var/log/mysql/mariadb-relay-bin
read_only = ON
bind-address = 0.0.0.0
EOF

# Restart MariaDB
service mariadb restart

until mariadb -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

echo "=== Status Slave ==="
mariadb -e "SHOW VARIABLES LIKE 'server_id';"
mariadb -e "SHOW VARIABLES LIKE 'read_only';"
echo "Konfigurasi Slave selesai."
echo "Selanjutnya atur CHANGE MASTER TO secara manual."