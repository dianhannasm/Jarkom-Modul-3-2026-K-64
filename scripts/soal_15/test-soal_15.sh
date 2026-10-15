#!/bin/bash

# Mengirim 40 request melalui Load Balancer geto
# lalu menghitung jumlah respons dari setiap worker.

for i in $(seq 1 40); do
    curl -fsS --max-time 5 \
        -H "Host: api.jujutsu.k64.com" \
        "http://127.0.0.1/?test_soal15=$i"
    echo
done | grep -o '"hostname":"[^"]*"' | sort | uniq -c