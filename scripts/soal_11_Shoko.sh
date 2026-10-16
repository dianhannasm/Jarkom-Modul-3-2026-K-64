#!/bin/bash
set -e
# SOAL 11 - DNS SLAVE SHOKO (script dari chat)
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 bind9utils dnsutils
if [ -f /etc/bind/named.conf.local ]; then
    cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak
fi
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.k64.com" {
    type slave;
    file "/var/cache/bind/db.jujutsu.k64.com";
    masters { 192.243.1.2; };
    allow-notify { 192.243.1.2; };
};
EOF
named-checkconf
service named restart || service bind9 restart
echo 'DNS Slave Shoko berhasil dikonfigurasi!'
