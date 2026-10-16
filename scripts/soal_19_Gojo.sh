#!/bin/bash
set -e
# SOAL 19 - GOJO
# Proxy Caching frontend 10 menit + rate limit API 10 req/s/IP
# Sesuai script yang diberikan dan berhasil diverifikasi MISS/HIT, HTTP 429.
SITE="/etc/nginx/sites-available/web-proxy"
BACKUP="/root/web-proxy.before-soal19.bak"
if [ ! -f "$SITE" ]; then
    echo 'ERROR: Konfigurasi web-proxy belum ada. Pulihkan Soal 17 dahulu.'
    exit 1
fi
if [ ! -f "$BACKUP" ]; then
    cp "$SITE" "$BACKUP"
fi
mkdir -p /var/cache/nginx/jujutsu
chown -R www-data:www-data /var/cache/nginx/jujutsu
cat > /etc/nginx/conf.d/soal_19.conf <<'NGINX'
proxy_cache_path /var/cache/nginx/jujutsu
    levels=1:2
    keys_zone=jujutsu_cache:10m
    max_size=100m
    inactive=10m
    use_temp_path=off;
limit_req_zone $binary_remote_addr
    zone=api_limit:10m
    rate=10r/s;
NGINX
cat > "$SITE" <<'NGINX'
upstream web_workers {
    server 192.243.4.12:80;
    server 192.243.4.13:80;
}
server {
    listen 80;
    server_name jujutsu.k64.com www.jujutsu.k64.com;
    location /api {
        limit_req zone=api_limit burst=5 nodelay;
        limit_req_status 429;
        proxy_pass http://192.243.4.11;
        proxy_set_header Host api.jujutsu.k64.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    location / {
        proxy_cache jujutsu_cache;
        proxy_cache_valid 200 10m;
        proxy_cache_lock on;
        add_header X-Cache-Status $upstream_cache_status always;
        proxy_pass http://web_workers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX
ln -sfn "$SITE" /etc/nginx/sites-enabled/web-proxy
if ! nginx -t; then
    echo 'Konfigurasi gagal, memulihkan konfigurasi sebelumnya...'
    cp "$BACKUP" "$SITE"
    rm -f /etc/nginx/conf.d/soal_19.conf
    nginx -t
    exit 1
fi
service nginx reload
echo '=================================='
echo 'SOAL 19 BERHASIL DIKONFIGURASI'
echo 'Frontend cache : 10 menit'
echo 'API rate limit : 10 req/s/IP'
echo 'Rate limit HTTP: 429'
echo '=================================='
