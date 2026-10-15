#!/bin/bash
set -e

# Soal 17 - Gojo
# Meneruskan IP asli klien ke Geto dan worker frontend.

cat > /etc/nginx/sites-available/web-proxy <<'NGINX'
upstream web_workers {
    server 192.243.4.12:80;
    server 192.243.4.13:80;
}

server {
    listen 80;
    server_name jujutsu.k64.com www.jujutsu.k64.com;

    location /api {
        proxy_pass http://192.243.4.11;
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

nginx -t
service nginx reload
echo "Soal 17 Gojo selesai."