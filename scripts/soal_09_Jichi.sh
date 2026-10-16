#!/bin/bash
set -e
# REKONSTRUKSI SOAL 9 - simulasi DHCP Relay down/up di Jichi.
case "${1:-status}" in
    stop)    service isc-dhcp-relay stop ;;
    start)   service isc-dhcp-relay start ;;
    restart) service isc-dhcp-relay restart ;;
    status)  service isc-dhcp-relay status ;;
    *) echo 'Gunakan: bash /root/soal_9.sh {stop|start|restart|status}'; exit 1 ;;
esac
