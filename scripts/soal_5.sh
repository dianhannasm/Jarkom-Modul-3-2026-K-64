
#!/bin/bash
set -e

# SOAL 5 - DHCP SHORT LEASE, LONG LEASE, DNS, DOMAIN
# Kelompok K-64
# Prefix IP: 192.243
# Domain: k64.com

cat > /etc/dhcp/dhcpd.conf <<'EOF'
authoritative;

default-lease-time 600;
max-lease-time 7200;

subnet 192.243.4.0 netmask 255.255.255.0 {
}

# SOAL 4 - CLASS NETWORK 2
class "dev" {
    match if
        hardware = 1:02:42:ef:7f:1a:00 or
        hardware = 1:02:42:d2:a0:1a:00;
}

class "support" {
    match if
        hardware = 1:02:42:7e:e8:3a:00 or
        hardware = 1:02:42:0c:15:70:00;
}

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

# SOAL 5 - CLASS NETWORK 3
class "short-lease" {
    match if
        hardware = 1:02:42:30:30:8f:00 or
        hardware = 1:02:42:16:89:27:00;
}

class "long-lease" {
    match if hardware = 1:02:42:cd:10:0d:00;
}

subnet 192.243.3.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option routers 192.243.3.1;
    option domain-name-servers 192.243.1.2, 192.243.1.3;
    option domain-name "k64.com";
    option domain-search "k64.com";

    pool {
        range 192.243.3.10 192.243.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
        allow members of "short-lease";
    }

    pool {
        range 192.243.3.100 192.243.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
        allow members of "long-lease";
    }
}
EOF

# Validasi konfigurasi sebelum restart
dhcpd -t -4 -cf /etc/dhcp/dhcpd.conf

# Restart DHCP Server
service isc-dhcp-server restart

echo "Konfigurasi Soal 5 selesai!"