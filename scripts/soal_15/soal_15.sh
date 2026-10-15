#!/bin/bash
set -e

# Soal 15 - Nginx Load Balancer API
# nanami: 192.243.4.14, bobot 3
# todo:   192.243.4.15, bobot 1

# Backup konfigurasi Soal 14 jika backup belum ada
if [ ! -f /etc/nginx/sites-available/api-proxy.soal14.bak ]; then
    cp /etc/nginx/sites-available/api-proxy \
       /etc/nginx/sites-available/api-proxy.soal14.bak
fi

# Membuat konfigurasi Weighted Round Robin
cat > /etc/nginx/sites-available/api-proxy <<'NGINX'
upstream api_cluster {
    server 192.243.4.14:80 weight=3;
    server 192.243.4.15:80 weight=1;
}

server {
    listen 80;
    server_name api.jujutsu.k64.com;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host api.jujutsu.k64.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX

# Aktifkan konfigurasi proxy
ln -sf /etc/nginx/sites-available/api-proxy \
       /etc/nginx/sites-enabled/api-proxy

# Validasi konfigurasi sebelum reload
nginx -t

# Terapkan konfigurasi
service nginx reload

echo "Soal 15: Load Balancer API berhasil dikonfigurasi."