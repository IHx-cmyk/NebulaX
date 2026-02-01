#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}"
echo "========================================"
echo "    MENGHAPUS NEBULA-X...               "
echo "========================================"
echo -e "${NC}"

# Hapus folder instalasi
if [ -d "$HOME/.nebulaX" ]; then
    rm -rf "$HOME/.nebulaX"
    echo -e "${GREEN}[*] Folder NebulaX dihapus.${NC}"
fi

# Hapus config
rm "$HOME/.zshrc"

# Restore backup jika ada
if [ -f "$HOME/.zshrc.backup_nebulaX" ]; then
    mv "$HOME/.zshrc.backup_nebulaX" "$HOME/.zshrc"
    echo -e "${GREEN}[*] Konfigurasi lama dikembalikan.${NC}"
else
    # Jika tidak ada backup, buat .zshrc kosong default
    echo "" > "$HOME/.zshrc"
fi

# Kembalikan ke bash
chsh -s bash
echo -e "${GREEN}[*] Shell dikembalikan ke Bash.${NC}"

echo -e "${GREEN}Penghapusan selesai. Restart Termux kamu.${NC}"
