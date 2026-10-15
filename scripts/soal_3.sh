#!/bin/bash
set -e

# SOAL 3 - DHCP RELAY
# Kelompok K-64

apt-get update
apt-get install -y isc-dhcp-relay

cat > /etc/default/isc-dhcp-relay <<'EOF'
SERVERS="192.243.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF

service isc-dhcp-relay restart

echo "Soal 3 - Konfigurasi DHCP Relay selesai!"