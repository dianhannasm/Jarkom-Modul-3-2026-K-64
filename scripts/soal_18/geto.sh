set -e

# Soal 18 - Geto
# Nanami dan Todo = worker utama
# Kirara = worker cadangan
# Passive health check: max_fails=2, fail_timeout=5s

if [ ! -f /etc/nginx/sites-available/api-proxy.soal18.bak ]; then
    cp /etc/nginx/sites-available/api-proxy \
       /etc/nginx/sites-available/api-proxy.soal18.bak
fi

cat > /etc/nginx/sites-available/api-proxy <<'NGINX'
upstream api_cluster {
    server 192.243.4.14:80 weight=3 max_fails=2 fail_timeout=5s;
    server 192.243.4.15:80 weight=1 max_fails=2 fail_timeout=5s;
    server 192.243.4.16:80 backup;
}

server {
    listen 80;
    server_name api.jujutsu.k64.com;

    # Percayai IP klien hanya dari Gojo
    set_real_ip_from 192.243.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host api.jujutsu.k64.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/api-proxy \
       /etc/nginx/sites-enabled/api-proxy

nginx -t
service nginx reload

echo "Soal 18 Geto: Kirara sudah dikonfigurasi sebagai backup."