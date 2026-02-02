#!/usr/bin/env bash

# =============================================================================
# nebulaX Uninstaller
# =============================================================================

# Warna untuk output
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[97m'
BOLD='\033[1m'
NC='\033[0m'

# Fungsi untuk header
show_header() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    cat << "EOF"
    _   __      ______  __    _    ______
   / | / /___  / __/ / / /   | |  / / / /
  /  |/ / __ \/ /_/ / / /    | | / / / / 
 / /|  / /_/ / __/ /_/ /     | |/ / /_/  
/_/ |_/\____/_/  \____/      |___/\____/  
EOF
    echo -e "${NC}"
    echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════╗"
    echo -e "║            NEBULAX UNINSTALLER              ║"
    echo -e "╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fungsi untuk konfirmasi
confirm_uninstall() {
    echo -e "${YELLOW}⚠  PERINGATAN: Ini akan menghapus nebulaX sepenuhnya!${NC}"
    echo ""
    echo -e "Yang akan dihapus:"
    echo -e "  • ${WHITE}~/.nebulaX${NC} (folder utama nebulaX)"
    echo -e "  • ${WHITE}~/.zshrc${NC} (konfigurasi ZSH nebulaX)"
    echo -e "  • ${WHITE}Path di .profile/.bashrc${NC}"
    echo ""
    echo -e "Yang akan dikembalikan:"
    echo -e "  • ${GREEN}Backup konfigurasi lama${NC} (jika ada)"
    echo ""
    
    read -p "Apakah Anda yakin ingin uninstall nebulaX? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Uninstall dibatalkan.${NC}"
        exit 0
    fi
    echo ""
}

# Fungsi untuk restore backup
restore_backups() {
    echo -e "${CYAN}→ Mencari backup konfigurasi...${NC}"
    
    # Cari backup terbaru
    ZSH_BACKUP=$(ls -t ~/.zshrc.backup.* 2>/dev/null | head -1)
    OMZ_BACKUP=$(ls -td ~/.oh-my-zsh.backup.* 2>/dev/null | head -1)
    
    # Restore .zshrc
    if [ -f "$ZSH_BACKUP" ]; then
        echo -e "${GRAY}  • Restoring .zshrc dari: $(basename "$ZSH_BACKUP")${NC}"
        cp "$ZSH_BACKUP" ~/.zshrc 2>/dev/null
        echo -e "${GREEN}  ✓ .zshrc berhasil dikembalikan${NC}"
    else
        # Coba restore dari backup lain
        if [ -f ~/.zshrc.bak.pre-nebulax ]; then
            echo -e "${GRAY}  • Restoring .zshrc dari backup lama${NC}"
            cp ~/.zshrc.bak.pre-nebulax ~/.zshrc 2>/dev/null
            echo -e "${GREEN}  ✓ .zshrc berhasil dikembalikan${NC}"
        elif [ -f ~/.zshrc.original ]; then
            echo -e "${GRAY}  • Restoring .zshrc dari original${NC}"
            cp ~/.zshrc.original ~/.zshrc 2>/dev/null
            echo -e "${GREEN}  ✓ .zshrc berhasil dikembalikan${NC}"
        else
            # Buat .zshrc default sederhana
            echo -e "${YELLOW}  ⚠  Tidak ada backup .zshrc ditemukan${NC}"
            echo -e "${GRAY}  • Membuat .zshrc default...${NC}"
            cat > ~/.zshrc << 'EOF'
# Default ZSH configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
EOF
            echo -e "${GREEN}  ✓ .zshrc default dibuat${NC}"
        fi
    fi
    
    # Restore oh-my-zsh
    if [ -d "$OMZ_BACKUP" ]; then
        echo -e "${GRAY}  • Restoring oh-my-zsh dari: $(basename "$OMZ_BACKUP")${NC}"
        rm -rf ~/.oh-my-zsh 2>/dev/null
        cp -r "$OMZ_BACKUP" ~/.oh-my-zsh 2>/dev/null
        echo -e "${GREEN}  ✓ oh-my-zsh berhasil dikembalikan${NC}"
    fi
    
    echo -e "${GREEN}✓ Backup restoration complete${NC}"
}

# Fungsi untuk hapus nebulaX
remove_nebulax() {
    echo -e "${CYAN}→ Menghapus nebulaX...${NC}"
    
    NEBULA_DIR="$HOME/.nebulaX"
    
    # Hapus folder utama nebulaX
    if [ -d "$NEBULA_DIR" ]; then
        echo -e "${GRAY}  • Menghapus folder nebulaX...${NC}"
        rm -rf "$NEBULA_DIR"
        echo -e "${GREEN}  ✓ Folder nebulaX dihapus${NC}"
    else
        echo -e "${YELLOW}  ⚠  Folder nebulaX tidak ditemukan${NC}"
    fi
    
    # Hapus path dari .profile
    if [ -f ~/.profile ]; then
        echo -e "${GRAY}  • Membersihkan .profile...${NC}"
        sed -i '/NEBULA_HOME/d' ~/.profile 2>/dev/null
        sed -i '/\.nebulaX/d' ~/.profile 2>/dev/null
        echo -e "${GREEN}  ✓ .profile dibersihkan${NC}"
    fi
    
    # Hapus path dari .bashrc
    if [ -f ~/.bashrc ]; then
        echo -e "${GRAY}  • Membersihkan .bashrc...${NC}"
        sed -i '/NEBULA_HOME/d' ~/.bashrc 2>/dev/null
        sed -i '/\.nebulaX/d' ~/.bashrc 2>/dev/null
        echo -e "${GREEN}  ✓ .bashrc dibersihkan${NC}"
    fi
    
    # Hapus backup files nebulaX
    echo -e "${GRAY}  • Membersihkan file backup nebulaX...${NC}"
    rm -f ~/.zshrc.bak.pre-nebulax 2>/dev/null
    rm -f ~/.zshrc.backup.* 2>/dev/null
    rm -f ~/.bashrc.backup.* 2>/dev/null
    echo -e "${GREEN}  ✓ File backup dibersihkan${NC}"
    
    echo -e "${GREEN}✓ nebulaX removal complete${NC}"
}

# Fungsi untuk reset shell
reset_shell() {
    echo -e "${CYAN}→ Reset shell default...${NC}"
    
    # Deteksi shell asli
    ORIGINAL_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7 2>/dev/null)
    
    if [ -z "$ORIGINAL_SHELL" ] || [[ "$ORIGINAL_SHELL" == *"zsh"* ]]; then
        # Coba set ke bash jika tersedia
        if command -v bash >/dev/null 2>&1; then
            ORIGINAL_SHELL=$(which bash)
        else
            ORIGINAL_SHELL="/bin/sh"
        fi
    fi
    
    echo -e "${GRAY}  • Mengatur shell default ke: $ORIGINAL_SHELL${NC}"
    
    # Coba ubah shell dengan chsh
    if command -v chsh >/dev/null 2>&1; then
        chsh -s "$ORIGINAL_SHELL" 2>/dev/null && \
        echo -e "${GREEN}  ✓ Shell default diubah${NC}" || \
        echo -e "${YELLOW}  ⚠  Gagal mengubah shell default${NC}"
    else
        echo -e "${YELLOW}  ⚠  chsh tidak tersedia, shell tetap ZSH${NC}"
        echo -e "${GRAY}    Jalankan 'chsh -s $(which bash)' secara manual${NC}"
    fi
    
    echo -e "${GREEN}✓ Shell reset complete${NC}"
}

# Fungsi untuk verifikasi uninstall
verify_uninstall() {
    echo -e "${CYAN}→ Verifikasi uninstall...${NC}"
    
    echo -e "${GRAY}  • Memeriksa folder nebulaX...${NC}"
    if [ ! -d "$HOME/.nebulaX" ]; then
        echo -e "${GREEN}  ✓ Folder nebulaX tidak ditemukan${NC}"
    else
        echo -e "${RED}  ✗ Masih ada folder nebulaX!${NC}"
    fi
    
    echo -e "${GRAY}  • Memeriksa konfigurasi...${NC}"
    if ! grep -q "NEBULA_HOME" ~/.zshrc 2>/dev/null && \
       ! grep -q "\.nebulaX" ~/.zshrc 2>/dev/null; then
        echo -e "${GREEN}  ✓ Konfigurasi nebulaX dibersihkan${NC}"
    else
        echo -e "${YELLOW}  ⚠  Masih ada referensi nebulaX di .zshrc${NC}"
    fi
    
    echo -e "${GREEN}✓ Verification complete${NC}"
}

# Fungsi untuk pilihan cleanup
choose_cleanup() {
    echo ""
    echo -e "${CYAN}Pilihan cleanup tambahan:${NC}"
    echo ""
    echo "1. Hapus SEMUA backup (termasuk yang lama)"
    echo "2. Hapus hanya backup nebulaX"
    echo "3. Simpan semua backup"
    echo "4. Lihat daftar backup"
    echo ""
    
    read -p "Pilihan Anda (1-4, default 3): " cleanup_choice
    echo ""
    
    case $cleanup_choice in
        1)
            echo -e "${RED}→ Menghapus SEMUA backup...${NC}"
            rm -f ~/.zshrc.backup.* ~/.bashrc.backup.* 2>/dev/null
            rm -f ~/.zshrc.bak.* ~/.bashrc.bak.* 2>/dev/null
            rm -rf ~/.oh-my-zsh.backup.* 2>/dev/null
            echo -e "${GREEN}✓ Semua backup dihapus${NC}"
            ;;
        2)
            echo -e "${YELLOW}→ Menghapus hanya backup nebulaX...${NC}"
            rm -f ~/.zshrc.bak.pre-nebulax 2>/dev/null
            rm -f ~/.zshrc.backup.* 2>/dev/null
            echo -e "${GREEN}✓ Backup nebulaX dihapus${NC}"
            ;;
        3)
            echo -e "${GREEN}→ Menyimpan semua backup${NC}"
            ;;
        4)
            echo -e "${CYAN}Daftar backup yang ditemukan:${NC}"
            echo ""
            find ~ -maxdepth 1 -name "*.backup.*" -o -name "*.bak.*" -o -name "*pre-nebulax" 2>/dev/null | \
            while read -r backup; do
                size=$(du -h "$backup" 2>/dev/null | cut -f1)
                echo "  • $(basename "$backup") ($size)"
            done
            echo ""
            read -p "Tekan Enter untuk melanjutkan..."
            choose_cleanup  # Kembali ke menu pilihan
            ;;
        *)
            echo -e "${GREEN}→ Menyimpan semua backup (default)${NC}"
            ;;
    esac
}

# Fungsi untuk final message
show_final_message() {
    echo ""
    echo -e "${RED}${BOLD}══════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}nebulaX telah diuninstall sepenuhnya!${NC}"
    echo ""
    echo -e "${YELLOW}Langkah selanjutnya:${NC}"
    echo -e "  1. ${CYAN}Tutup terminal saat ini${NC}"
    echo -e "  2. ${CYAN}Buka terminal baru${NC}"
    echo -e "  3. ${CYAN}Konfigurasi lama akan aktif kembali${NC}"
    echo ""
    
    if command -v zsh >/dev/null 2>&1 && [ -f ~/.zshrc ]; then
        echo -e "${GREEN}ZSH masih terinstall dengan konfigurasi default/backup.${NC}"
    fi
    
    echo -e "${MAGENTA}Terima kasih telah menggunakan nebulaX!${NC}"
    echo -e "${RED}${BOLD}══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Tanya apakah mau hapus script ini juga
    read -p "Hapus script uninstall ini juga? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GRAY}Menghapus remove.sh...${NC}"
        rm -f "$0"
        echo -e "${GREEN}✓ Script uninstall dihapus${NC}"
    fi
}

# Fungsi utama
main() {
    show_header
    confirm_uninstall
    restore_backups
    remove_nebulax
    reset_shell
    verify_uninstall
    choose_cleanup
    show_final_message
}

# Error handling
set -e

trap 'echo -e "\n${RED}Error terjadi! Uninstall dihentikan.${NC}"; exit 1' ERR

# Jalankan fungsi utama
main "$@"