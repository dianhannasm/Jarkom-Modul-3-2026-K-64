#!/bin/bash
set -e

# SOAL 12 - DNS A, CNAME, PTR, DAN FORWARDER
# Kelompok K-64
# Domain: jujutsu.k64.com

apt-get install -y bind9 bind9-utils dnsutils

# Backup konfigurasi sebelumnya
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak
cp /etc/bind/db.jujutsu.k64.com /etc/bind/db.jujutsu.k64.com.bak

# Konfigurasi zona forward dan reverse
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.k64.com" {
    type master;
    file "/etc/bind/db.jujutsu.k64.com";

    allow-transfer { 192.243.1.3; };
    also-notify { 192.243.1.3; };
    notify yes;
};

zone "1.243.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.243.1";

    allow-transfer { 192.243.1.3; };
    also-notify { 192.243.1.3; };
    notify yes;
};
EOF

# A record dan CNAME
cat > /etc/bind/db.jujutsu.k64.com <<'EOF'
$TTL 604800
@ IN SOA ns1.jujutsu.k64.com. admin.jujutsu.k64.com. (
    2026101403
    604800
    86400
    2419200
    604800
)

@    IN NS ns1.jujutsu.k64.com.
@    IN NS ns2.jujutsu.k64.com.

ns1  IN A     192.243.1.2
ns2  IN A     192.243.1.3
@    IN A     192.243.1.4
www  IN CNAME jujutsu.k64.com.
EOF

# Reverse DNS PTR untuk gojo
cat > /etc/bind/db.192.243.1 <<'EOF'
$TTL 604800
@ IN SOA ns1.jujutsu.k64.com. admin.jujutsu.k64.com. (
    2026101403
    604800
    86400
    2419200
    604800
)

@ IN NS ns1.jujutsu.k64.com.
@ IN NS ns2.jujutsu.k64.com.

4 IN PTR jujutsu.k64.com.
EOF

# DNS Forwarder ke gateway internet
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };
    allow-recursion { any; };

    forwarders {
        192.168.122.1;
    };

    dnssec-validation auto;
};
EOF

# Validasi konfigurasi dan kedua zona
named-checkconf
named-checkzone jujutsu.k64.com /etc/bind/db.jujutsu.k64.com
named-checkzone 1.243.192.in-addr.arpa /etc/bind/db.192.243.1

# Restart DNS Master
service named restart

echo "Konfigurasi Soal 12 selesai!"