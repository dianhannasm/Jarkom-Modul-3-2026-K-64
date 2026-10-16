#!/bin/bash
set -e
# REKONSTRUKSI SOAL 10 - restore Jichi NAT + DHCP Relay saat container restart.
# Salin file ini ke Jichi sebagai /root/soal_10.sh, bersama /root/soal_1.sh & /root/soal_3.sh.
# Setelah script init terpasang, jalankan setup saat boot (lihat 03_pembantu/init_DebiNet.contoh.sh).
if [ -f /root/soal_1.sh ]; then bash /root/soal_1.sh; fi
if ! command -v iptables >/dev/null 2>&1 || ! command -v dhcrelay >/dev/null 2>&1; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y iptables isc-dhcp-relay
fi
if [ -f /root/soal_3.sh ]; then
    bash /root/soal_3.sh
else
    cat > /etc/default/isc-dhcp-relay <<'CONF'
SERVERS="192.243.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
CONF
    service isc-dhcp-relay restart
fi
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service isc-dhcp-relay status
