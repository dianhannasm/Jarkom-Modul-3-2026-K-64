#!/bin/bash
set -e
# REKONSTRUKSI SOAL 8 - capture DHCP DORA di Tengen.
# Saat capture berjalan, renew DHCP client (contoh Ino) dari console lain.
if ! command -v tcpdump >/dev/null 2>&1; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y tcpdump
fi
echo 'Capturing DHCP selama 60 detik -> /root/soal_8.pcap'
timeout 60 tcpdump -i eth0 -nn -s 0 -w /root/soal_8.pcap 'udp port 67 or udp port 68' || status=$?
if [ "${status:-0}" -ne 0 ] && [ "${status:-0}" -ne 124 ]; then exit "$status"; fi
echo 'Lihat isi: tcpdump -r /root/soal_8.pcap -nn -vv'
