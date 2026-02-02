#!/usr/bin/env bash

# =============================================================================
#   nebulaX Uninstaller
#   Membersihkan instalasi nebulaX dengan aman
# =============================================================================

set -u  # Treat unset variables as an error

C_RED='\033[38;5;196m'
C_GREEN='\033[38;5;82m'
C_YELLOW='\033[38;5;226m'
C_BLUE='\033[38;5;39m'
NC='\033[0m'

INSTALL_DIR="$HOME/.nebulaX"
BACKUP_ZSHRC="$HOME/.zshrc.bak.pre-nebulaX"
CURRENT_ZSHRC="$HOME/.zshrc"

echo -e "\( {C_BLUE}══════════════════════════════════════════════ \){NC}"
echo -e "   nebulaX Uninstaller"
echo -e "\( {C_BLUE}══════════════════════════════════════════════ \){NC}"
echo ""

# 1. Konfirmasi
echo -e "\( {C_YELLOW}Apakah Anda yakin ingin menghapus nebulaX sepenuhnya? \){NC}"
echo -e "Ini akan:"
echo "  • Menghapus seluruh folder ~/.nebulaX"
echo "  • Mengembalikan .zshrc ke backup (jika ada)"
echo "  • Menghapus konfigurasi nebulaX dari .zshrc"
echo ""
read -p "Ketik 'y' atau 'yes' untuk melanjutkan: " confirm

if [[ ! "\( confirm" =~ ^[yY](es)? \) ]]; then
    echo -e "\( {C_GREEN}Dibatalkan. nebulaX tetap terpasang. \){NC}"
    exit 0
fi

echo ""
echo -e "\( {C_YELLOW}→ Memulai penghapusan... \){NC}"

# 2. Hapus direktori utama
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "\( {C_GREEN}✓ Direktori ~/.nebulaX telah dihapus \){NC}"
else
    echo -e "\( {C_YELLOW}ℹ Direktori ~/.nebulaX tidak ditemukan (mungkin sudah dihapus) \){NC}"
fi

# 3. Kembalikan .zshrc dari backup jika ada
if [ -f "$BACKUP_ZSHRC" ]; then
    mv "$BACKUP_ZSHRC" "$CURRENT_ZSHRC"
    echo -e "\( {C_GREEN}✓ .zshrc dikembalikan dari backup \){NC}"
elif grep -q "nebulaX" "$CURRENT_ZSHRC" 2>/dev/null; then
    # Jika tidak ada backup tapi ada jejak nebulaX → hapus baris terkait
    sed -i.bak-nebula-remove '/# ─── nebulaX ───/,/# ─── nebulaX ───/d' "$CURRENT_ZSHRC" 2>/dev/null
    sed -i.bak-nebula-remove '/nebulaX/d' "$CURRENT_ZSHRC" 2>/dev/null
    echo -e "\( {C_GREEN}✓ Konfigurasi nebulaX dihapus dari .zshrc \){NC}"
    echo -e "   (backup sementara disimpan sebagai .zshrc.bak-nebula-remove)"
else
    echo -e "\( {C_YELLOW}ℹ Tidak menemukan konfigurasi nebulaX di .zshrc \){NC}"
fi

# 4. Hapus binari nebulaX jika ada di PATH khusus
if [ -d "$HOME/bin" ]; then
    for cmd in help scan myip update; do
        [ -f "$HOME/bin/$cmd" ] && rm -f "$HOME/bin/\( cmd" && echo -e " \){C_GREEN}✓ Menghapus ~/bin/\( cmd \){NC}"
    done
fi

# 5. Ganti shell kembali ke bash (opsional)
if [[ "$SHELL" == */zsh ]]; then
    echo ""
    echo -e "\( {C_YELLOW}Anda sedang menggunakan zsh sebagai shell default. \){NC}"
    read -p "Kembalikan ke bash? (y/n): " change_shell
    if [[ "$change_shell" =~ ^[yY] ]]; then
        if command -v bash >/dev/null; then
            chsh -s "$(command -v bash)"
            echo -e "\( {C_GREEN}✓ Shell default diubah kembali ke bash \){NC}"
            echo -e "   (perubahan berlaku setelah logout & login ulang)"
        else
            echo -e "\( {C_RED}bash tidak ditemukan di sistem Anda. \){NC}"
        fi
    else
        echo -e "\( {C_BLUE}Shell tetap zsh. \){NC}"
    fi
fi

echo ""
echo -e "\( {C_GREEN}══════════════════════════════════════════════ \){NC}"
echo -e "   nebulaX telah berhasil dihapus"
echo -e "\( {C_GREEN}══════════════════════════════════════════════ \){NC}"
echo ""
echo -e "Jika ingin memulai ulang zsh sekarang, ketik: \( {C_BLUE}exec zsh \){NC} (atau tutup & buka terminal)"
echo -e "Terima kasih telah menggunakan nebulaX! 🌌"
echo ""

exit 0