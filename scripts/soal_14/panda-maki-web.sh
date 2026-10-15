#!/bin/bash
set -e

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php-fpm

# Deteksi socket PHP-FPM
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
PHP_SOCK="/run/php/php${PHP_VERSION}-fpm.sock"

# Tunggu socket PHP-FPM tersedia
systemctl enable --now "php${PHP_VERSION}-fpm"
systemctl enable --now nginx

# Buat halaman yang menampilkan hostname worker
mkdir -p /var/www/jujutsu
cat > /var/www/jujutsu/index.php <<'PHP'
<?php
header('Content-Type: text/html; charset=UTF-8');
echo '<h1>Jujutsu Kaisen Web Worker</h1>';
echo '<p>Hostname: ' . htmlspecialchars(gethostname(), ENT_QUOTES, 'UTF-8') . '</p>';
echo '<p>PHP-FPM aktif.</p>';
?>
PHP

# Virtual host web worker
cat > /etc/nginx/sites-available/jujutsu <<EOF
server {
    listen 80;
    server_name jujutsu.k64.com www.jujutsu.k64.com;

    root /var/www/jujutsu;
    index index.php index.html;

    # Hanya Gojo dan localhost yang diizinkan
    allow 192.243.1.4;
    allow 127.0.0.1;
    deny all;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${PHP_SOCK};
    }
}
EOF

# Aktifkan virtual host
ln -sf /etc/nginx/sites-available/jujutsu \
    /etc/nginx/sites-enabled/jujutsu
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart "php${PHP_VERSION}-fpm"
systemctl restart nginx

echo "=== Web worker siap ==="
hostname
systemctl is-active nginx
systemctl is-active "php${PHP_VERSION}-fpm"