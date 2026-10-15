#!/bin/bash
set -e

# SOAL 4 - DHCP CLASS DAN PEMBAGIAN POOL
# Kelompok K-64
# Prefix IP: 192.243

cat > /etc/dhcp/dhcpd.conf <<'EOF'
authoritative;

default-lease-time 600;
max-lease-time 7200;

# Network 4 - Data Center
subnet 192.243.4.0 netmask 255.255.255.0 {
}

# Class Dev: itadori dan fushiguro
class "dev" {
    match if
        hardware = 1:02:42:ef:7f:1a:00 or
        hardware = 1:02:42:d2:a0:1a:00;
}

# Class Support: zenin dan okkotsu
class "support" {
    match if
        hardware = 1:02:42:7e:e8:3a:00 or
        hardware = 1:02:42:0c:15:70:00;
}

# Network 2 - Divisi A
subnet 192.243.2.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option routers 192.243.2.1;
    option domain-name-servers 192.168.122.1;

    pool {
        range 192.243.2.10 192.243.2.35;
        allow members of "dev";
    }

    pool {
        range 192.243.2.70 192.243.2.95;
        allow members of "support";
    }
}

# Network 3 - Divisi B
subnet 192.243.3.0 netmask 255.255.255.0 {
    range 192.243.3.100 192.243.3.199;
    option subnet-mask 255.255.255.0;
    option routers 192.243.3.1;
    option domain-name-servers 192.168.122.1;
}
EOF

# Validasi sebelum restart
dhcpd -t -4 -cf /etc/dhcp/dhcpd.conf

# Terapkan konfigurasi
service isc-dhcp-server restart

echo "Soal 4 - DHCP Class dan Pool selesai!"