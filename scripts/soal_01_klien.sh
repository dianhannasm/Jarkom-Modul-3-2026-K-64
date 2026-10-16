#!/bin/sh
set -eu
# REKONSTRUKSI SOAL 1/7 - minta ulang IP DHCP pada klien Alpine.
ip link set eth0 up
udhcpc -i eth0 -q -n
ip -br -4 addr
ip route
cat /etc/resolv.conf
