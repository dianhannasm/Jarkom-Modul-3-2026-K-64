#!/bin/bash
set -e

# Soal 17 - Geto
# Hanya mempercayai X-Forwarded-For dari Gojo.

cat > /etc/nginx/sites-available/api-proxy <<'NGINX'
upstream api_cluster {
    server 192.243.4.14:80 weight=3;
    server 192.243.4.15:80 weight=1;
}

server {
    listen 80;
    server_name api.jujutsu.k64.com;

    set_real_ip_from 192.243.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host api.jujutsu.k64.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX

nginx -t
service nginx reload
echo "Soal 17 Geto selesai."