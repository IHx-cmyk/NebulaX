#!/usr/bin/env bash
# remove.sh - Uninstall nebulaX with Powerlevel10k

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}Uninstall nebulaX${NC}"
echo ""

read -p "Yakin mau uninstall? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo -e "${YELLOW}Menghapus nebulaX...${NC}"

# Restore original .zshrc jika ada backup
if [ -f "$HOME/.zshrc.backup"* ]; then
    BACKUP=$(ls -t "$HOME/.zshrc.backup"* | head -1)
    cp "$BACKUP" "$HOME/.zshrc"
    echo -e "${GREEN}✓ .zshrc dikembalikan${NC}"
fi

# Hapus folder nebulaX
rm -rf "$HOME/.nebulaX" 2>/dev/null

# Hapus konfigurasi p10k
rm -f "$HOME/.p10k.zsh" 2>/dev/null

# Hapus dari PATH
sed -i '/NEBULA_HOME/d' "$HOME/.profile" 2>/dev/null
sed -i '/\.nebulaX/d' "$HOME/.profile" 2>/dev/null
sed -i '/NEBULA_HOME/d' "$HOME/.bashrc" 2>/dev/null
sed -i '/\.nebulaX/d' "$HOME/.bashrc" 2>/dev/null

echo -e "${GREEN}✓ nebulaX berhasil diuninstall${NC}"
echo "Restart terminal untuk efek lengkap"