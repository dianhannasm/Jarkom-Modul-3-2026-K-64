#!/bin/bash
set -e

# Soal 16 - Path-Based Routing pada Gojo
# /     -> Maki dan Panda (Round Robin)
# /api  -> Geto (Load Balancer API)

# Backup konfigurasi sebelumnya jika belum ada
if [ ! -f /etc/nginx/sites-available/web-proxy.soal15.bak ]; then
    cp /etc/nginx/sites-available/web-proxy \
       /etc/nginx/sites-available/web-proxy.soal15.bak
fi

# Membuat konfigurasi Nginx
cat > /etc/nginx/sites-available/web-proxy <<'NGINX'
upstream web_workers {
    server 192.243.4.12:80;
    server 192.243.4.13:80;
}

upstream api_cluster_proxy {
    server 192.243.4.11:80;
}

server {
    listen 80;
    server_name jujutsu.k64.com www.jujutsu.k64.com;

    location = /api {
        proxy_pass http://api_cluster_proxy;
        proxy_set_header Host api.jujutsu.k64.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api/ {
        proxy_pass http://api_cluster_proxy;
        proxy_set_header Host api.jujutsu.k64.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        proxy_pass http://web_workers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX

# Aktifkan konfigurasi proxy
ln -sf /etc/nginx/sites-available/web-proxy \
       /etc/nginx/sites-enabled/web-proxy

# Validasi konfigurasi sebelum diterapkan
nginx -t

# Terapkan konfigurasi
service nginx reload

echo "Soal 16: Path-Based Routing berhasil dikonfigurasi."