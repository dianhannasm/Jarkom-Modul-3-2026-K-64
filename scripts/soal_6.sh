
#!/bin/bash
set -e

# SOAL 6 - DHCP STATIC LEASE KUGISAKI
# Kelompok K-64
# Prefix IP: 192.243

CONFIG="/etc/dhcp/dhcpd.conf"
BACKUP="/etc/dhcp/dhcpd.conf.backup-soal6"

# Simpan backup sebelum mengubah konfigurasi
cp "$CONFIG" "$BACKUP"

# Hapus blok host Kugisaki lama jika script dijalankan ulang,
# agar tidak terjadi deklarasi host duplikat.
python3 - "$CONFIG" <<'PY'
import re
import sys

path = sys.argv[1]

with open(path, "r") as f:
    config = f.read()

config = re.sub(
    r'\n?# SOAL 6 - DHCP STATIC LEASE KUGISAKI\s*'
    r'host kugisaki\s*\{[^{}]*\}\s*',
    '\n',
    config
)

with open(path, "w") as f:
    f.write(config.rstrip() + "\n")
PY

# Tambahkan reservasi IP Kugisaki
cat >> "$CONFIG" <<'EOF'

# SOAL 6 - DHCP STATIC LEASE KUGISAKI
host kugisaki {
    hardware ethernet 02:42:75:3d:8f:00;
    fixed-address 192.243.3.99;
}
EOF

# Validasi konfigurasi DHCP
dhcpd -t -4 -cf "$CONFIG"

# Restart DHCP Server
service isc-dhcp-server restart

echo "Konfigurasi Soal 6 berhasil diterapkan!"
echo "Kugisaki: 02:42:75:3d:8f:00 -> 192.243.3.99"
