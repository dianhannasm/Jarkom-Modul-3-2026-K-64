#!/bin/bash
set -e
# REKONSTRUKSI SOAL 1 - konfigurasi routing/IP sesuai topologi K-64.
# Salin sebagai /root/soal_1.sh pada node Debian, jalankan pada node sesuai hostname.
# Pada klien Alpine gunakan soal_01_klien.sh, bukan file ini.
NODE="$(hostname -s | tr '[:upper:]' '[:lower:]')"
set_static() {
    ip link set eth0 up
    ip -4 addr flush dev eth0
    ip addr add "$1/24" dev eth0
    ip route replace default via "$2" dev eth0
}
case "$NODE" in
    jichi)
        # NAT GNS3: eth0 = DHCP; biasanya 192.168.122.x gw 192.168.122.1.
        ip link set eth0 up
        if ! ip -4 addr show dev eth0 | grep -q 'inet '; then
            if command -v dhclient >/dev/null 2>&1; then
                dhclient -v eth0
            elif command -v udhcpc >/dev/null 2>&1; then
                udhcpc -i eth0 -q -n
            else
                echo 'PERINGATAN: Belum ada DHCP client untuk eth0 Jichi. Pulihkan eth0/NAT dahulu.' >&2
            fi
        fi
        for n in 1 2 3 4; do
            ip link set "eth$n" up
            ip -4 addr flush dev "eth$n"
            ip addr add "192.243.$n.1/24" dev "eth$n"
        done
        sysctl -w net.ipv4.ip_forward=1
        if command -v iptables >/dev/null 2>&1; then
            iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
                iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        else
            echo 'PERINGATAN: iptables belum terpasang; NAT belum dibuat.' >&2
        fi
        ;;
    utahime) set_static 192.243.1.2 192.243.1.1 ;;
    shoko)   set_static 192.243.1.3 192.243.1.1 ;;
    gojo)    set_static 192.243.1.4 192.243.1.1 ;;
    tengen)  set_static 192.243.4.10 192.243.4.1 ;;
    geto)    set_static 192.243.4.11 192.243.4.1 ;;
    maki)    set_static 192.243.4.12 192.243.4.1 ;;
    panda)   set_static 192.243.4.13 192.243.4.1 ;;
    nanami)  set_static 192.243.4.14 192.243.4.1 ;;
    todo)    set_static 192.243.4.15 192.243.4.1 ;;
    kirara)  set_static 192.243.4.16 192.243.4.1 ;;
    yaga)    set_static 192.243.4.17 192.243.4.1 ;;
    inumaki) set_static 192.243.4.18 192.243.4.1 ;;
    *) echo "Node $NODE tidak dikenal. Tidak mengubah konfigurasi." >&2; exit 1 ;;
esac
ip -br -4 addr
ip route
echo "Konfigurasi $NODE (Soal 1, rekonstruksi) selesai."
