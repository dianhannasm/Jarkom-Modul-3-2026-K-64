#!/bin/bash
set -e
# REKONSTRUKSI SOAL 10 - restore Tengen DHCP otomatis.
# Butuh file asli Soal 1,5,6; MAC kelas di script asli, atau /root/k64_macs.env.
if [ -f /root/soal_1.sh ]; then bash /root/soal_1.sh; fi
if ! command -v dhcpd >/dev/null 2>&1; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server python3
fi
if [ -f /etc/default/isc-dhcp-server ]; then
    sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server
fi
if [ ! -f /root/soal_5.sh ] || [ ! -f /root/soal_6.sh ]; then
    echo 'Soal 5 dan/atau Soal 6 belum ada pada /root. Restore file aslinya dahulu.' >&2
    exit 1
fi
bash /root/soal_5.sh
bash /root/soal_6.sh
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
