#!/bin/bash
set -e

# Soal 17 - API worker
# Hanya Geto yang boleh mengakses worker.
# PHP mencatat X-Real-IP hanya jika koneksi berasal dari Geto.

cat > /etc/nginx/sites-available/api-worker <<'NGINX'
server {
    listen 80;
    server_name api.jujutsu.k64.com;
    root /var/www/api;
    index index.php;

    allow 192.243.4.11;
    deny all;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
NGINX

# Ganti baris clientIp lama dengan validasi proxy.
python3 - <<'PY'
from pathlib import Path

p = Path("/var/www/api/index.php")
s = p.read_text()
old = "$clientIp = $_SERVER['REMOTE_ADDR'] ?? 'unknown';"
new = """$proxyIp = $_SERVER['REMOTE_ADDR'] ?? '';
$clientIp = ($proxyIp === '192.243.4.11')
    ? ($_SERVER['HTTP_X_REAL_IP'] ?? $proxyIp)
    : $proxyIp;"""

if old in s:
    s = s.replace(old, new, 1)
elif new not in s:
    raise SystemExit("Baris clientIp tidak ditemukan; file tidak diubah.")

p.write_text(s)
PY

nginx -t
service nginx reload
service php8.4-fpm restart
echo "Soal 17 API worker selesai."