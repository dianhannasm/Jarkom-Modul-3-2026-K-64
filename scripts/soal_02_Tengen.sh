#!/bin/bash
set -e
# REKONSTRUKSI SOAL 2 - DHCP server dasar di Tengen.
# Ini konfigurasi awal; lanjutkan Soal 4, 5, 6 agar pool sesuai soal.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server
sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server
cat > /etc/dhcp/dhcpd.conf <<'CONF'
authoritative;
default-lease-time 1800;
max-lease-time 43200;
option domain-name "k64.com";
option domain-name-servers 192.243.1.2, 192.243.1.3;
subnet 192.243.4.0 netmask 255.255.255.0 { }
subnet 192.243.2.0 netmask 255.255.255.0 {
    option routers 192.243.2.1;
}
subnet 192.243.3.0 netmask 255.255.255.0 {
    option routers 192.243.3.1;
}
CONF
# Soal 2 sengaja belum menambahkan DHCP pool.
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
