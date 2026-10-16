#!/bin/sh
set -eu
# SOAL 20 - APACHE BENCHMARK - Kusakabe
# Script yang diberikan selama praktikum, sudah terbukti dijalankan.
# Install sebelumnya: apk add apache2-utils
# Domain perlu resolve ke Gojo 192.243.1.4.
MODE="${1:-web}"
case "$MODE" in
    web)
        URL="http://jujutsu.k64.com/"
        OUTPUT="/root/soal_20_web.txt"
        ;;
    api-off)
        URL="http://jujutsu.k64.com/api?soal20=off"
        OUTPUT="/root/soal_20_api_off.txt"
        ;;
    api-on)
        URL="http://jujutsu.k64.com/api?soal20=on"
        OUTPUT="/root/soal_20_api_on.txt"
        ;;
    *)
        echo 'Penggunaan: sh /root/soal_20.sh {web|api-off|api-on}'
        exit 1
        ;;
esac
echo '======================================'
echo "SOAL 20 - BENCHMARK $MODE"
echo "Target      : $URL"
echo 'Requests    : 600'
echo 'Concurrency : 30'
echo '======================================'
ab -l -n 600 -c 30 "$URL" | tee "$OUTPUT"
echo "Hasil disimpan di: $OUTPUT"
