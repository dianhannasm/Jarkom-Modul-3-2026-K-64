#!/bin/sh
set -eu
# REKONSTRUKSI SOAL 7 - audit DHCP tiap klien Alpine.
echo "NODE: $(hostname)"
echo '=== IP ==='
ip -br -4 addr
echo '=== ROUTE ==='
ip route
echo '=== DNS ==='
cat /etc/resolv.conf
echo '=== PING GATEWAY + TENGEN ==='
GATEWAY=$(ip -4 route show default | awk 'NR==1{print $3}')
if [ -n "$GATEWAY" ]; then ping -c 2 "$GATEWAY"; fi
ping -c 2 192.243.4.10
