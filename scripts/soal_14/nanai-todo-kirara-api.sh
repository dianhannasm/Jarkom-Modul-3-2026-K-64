#!/bin/bash
set -e

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php-fpm php-mysql

mkdir -p /var/www/api

cat > /var/www/api/index.php <<'PHP'
<?php
header('Content-Type: application/json; charset=UTF-8');

$clientIp = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$requestPath = $_SERVER['REQUEST_URI'] ?? '/';
$statusCode = 200;

try {
    $pdo = new PDO(
        'mysql:host=192.243.4.17;dbname=db_shibuya_k64;charset=utf8mb4',
        'appuser',
        'K64App2026!',
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    $stmt = $pdo->prepare(
        'INSERT INTO request_logs (client_ip, request_path, status_code)
         VALUES (?, ?, ?)'
    );
    $stmt->execute([$clientIp, $requestPath, $statusCode]);

    echo json_encode([
        'message' => 'API worker aktif',
        'hostname' => gethostname(),
        'path' => $requestPath,
        'logged' => true
    ]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'message' => 'Gagal mencatat request ke database',
        'logged' => false
    ]);
}
?>
PHP

cat > /etc/nginx/sites-available/api-worker <<'EOF'
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
EOF

ln -sf /etc/nginx/sites-available/api-worker \
    /etc/nginx/sites-enabled/api-worker
rm -f /etc/nginx/sites-enabled/default

nginx -t
service php8.4-fpm restart || service php8.4-fpm start
service nginx restart || service nginx start

echo "API worker siap di $(hostname)"