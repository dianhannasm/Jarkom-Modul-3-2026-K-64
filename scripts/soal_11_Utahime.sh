#!/bin/bash
set -e
# SOAL 11 - DNS MASTER UTAHIME (berdasarkan script yg dikirim di chat)
# Tambahan A record web Gojo + serial 2026101403 dari langkah lanjutan.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 bind9utils dnsutils
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.k64.com" {
    type master;
    file "/etc/bind/db.jujutsu.k64.com";
    allow-transfer { 192.243.1.3; };
    also-notify { 192.243.1.3; };
    notify yes;
};
EOF
cat > /etc/bind/db.jujutsu.k64.com <<'EOF'
$TTL 604800
@ IN SOA ns1.jujutsu.k64.com. admin.jujutsu.k64.com. (
    2026101403 ; Serial
    604800     ; Refresh
    86400      ; Retry
    2419200    ; Expire
    604800 )   ; Negative TTL
@   IN NS ns1.jujutsu.k64.com.
@   IN NS ns2.jujutsu.k64.com.
ns1 IN A 192.243.1.2
ns2 IN A 192.243.1.3
@   IN A 192.243.1.4
www IN A 192.243.1.4
EOF
named-checkconf
named-checkzone jujutsu.k64.com /etc/bind/db.jujutsu.k64.com
service named restart || service bind9 restart
echo 'DNS Master Utahime berhasil dikonfigurasi!'
