#!/bin/bash

# --- WARNA NEBULAX ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

clear
echo -e "${PURPLE}"
echo "========================================"
echo " N E B U L A - X | UNIVERSAL v1       "
echo "========================================"
echo -e "${NC}"

# --- 1. DETEKSI OS & PACKAGE MANAGER ---
echo -e "${CYAN}[*] Mendeteksi Sistem Operasi...${NC}"

if [ -f /data/data/com.termux/files/usr/bin/bash ]; then
    OS_TYPE="Termux"
    INSTALLER="pkg install -y"
    SUDO=""
elif [ -f /etc/arch-release ]; then
    OS_TYPE="Arch Linux"
    INSTALLER="sudo pacman -S --noconfirm"
    SUDO="sudo"
elif [ -f /etc/debian_version ]; then
    OS_TYPE="Debian/Ubuntu/Kali"
    INSTALLER="sudo apt install -y"
    SUDO="sudo"
else
    OS_TYPE="Unknown"
    INSTALLER="pkg install -y" # Default fallback
    SUDO=""
fi

echo -e "${GREEN}    -> Sistem terdeteksi: $OS_TYPE"
echo -e "    -> Menggunakan installer: $INSTALLER ${NC}"

# --- 2. INSTALL DEPENDENCIES ---
echo -e "${CYAN}[*] Menginstall paket yang dibutuhkan...${NC}"
# Update repo dulu
if [[ "$OS_TYPE" == "Termux" ]]; then
    pkg update -y && pkg upgrade -y
elif [[ "$OS_TYPE" == "Debian/Ubuntu/Kali" ]]; then
    sudo apt update
fi

# Install paket (zsh, git, tools)
$INSTALLER zsh git curl wget tar unzip unrar grep bc net-tools

# --- 3. SETUP FOLDER ---
INSTALL_DIR="$HOME/.nebulaX"
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${PURPLE}[*] Mereset instalasi lama...${NC}"
fi
mkdir -p "$INSTALL_DIR/plugins"
mkdir -p "$INSTALL_DIR/bin"

# --- 4. DOWNLOAD PLUGINS ---
echo -e "${CYAN}[*] Mendownload Plugin ZSH...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions "$INSTALL_DIR/plugins/zsh-autosuggestions" --depth 1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$INSTALL_DIR/plugins/zsh-syntax-highlighting" --depth 1
git clone https://github.com/zsh-users/zsh-completions "$INSTALL_DIR/plugins/zsh-completions" --depth 1
git clone https://github.com/zsh-users/zsh-history-substring-search "$INSTALL_DIR/plugins/zsh-history-substring-search" --depth 1

# --- 5. BUAT BANNER VERTIKAL (ASCII ATAS, BOX BAWAH) ---
echo -e "${CYAN}[*] Meracik Tampilan Banner...${NC}"
cat > "$INSTALL_DIR/banner.sh" <<'EOF'
#!/bin/bash
# Warna
P1='\e[38;5;93m'   # Deep Purple
P2='\e[38;5;129m'  # Vivid Purple
P3='\e[38;5;141m'  # Light Purple
P4='\e[38;5;213m'  # Pink Accent
WT='\e[38;5;255m'  # White
RS='\e[0m'

# Info Gather
USER=$(whoami)
HOST=$(hostname)
KERNEL=$(uname -r | cut -d'-' -f1)

# Deteksi Nama OS yang cantik
if grep -q "Termux" /data/data/com.termux/files/usr/bin/login 2>/dev/null; then
    OS="Termux Android"
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$PRETTY_NAME
else
    OS=$(uname -o)
fi
# Potong nama OS kalau kepanjangan biar muat di box
OS=$(echo "$OS" | cut -c 1-20)

# Uptime logic
if [ -f /proc/uptime ]; then
    UPTIME=$(awk '{print int($1/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime)
else
    UPTIME="Unknown"
fi

clear
echo ""
# 1. ASCII ART (CENTERED FEEL)
echo -e "${P1}      .   ${P2},MMM8&&&. ${P1}   * "
echo -e "${P1}     * ${P2}MMMM88&&&&&    .  "
echo -e "${P1}        ${P2}MMMM88&&&&&&&      "
echo -e "${P1}    .   ${P2}MMM88&&&&&&&&      "
echo -e "${P1}        ${P2}'MMM88&&&&&&'      "
echo -e "${P1}          ${P2}'MMM8&&&'      * "
echo -e "${P2}      |\___/|${P4}   N E B U L A - X  "
echo -e "${P2}      )     (${P3}   U n i v e r s e  "
echo -e "${P2}     =\     /=${RS}                  "
echo -e "${P2}       ) . ( ${RS}                  "
echo -e "${P2}      /     \ ${RS}                 "

# 2. THE BOX (BELOW ASCII)
# Lebar box disesuaikan agar rapi
echo -e "${P1} ╭──────────────────────────────╮"
echo -e "${P1} │ ${P3}User   ${P2}: ${WT}$(printf '%-18s' "$USER") ${P1}│"
echo -e "${P1} │ ${P3}Host   ${P2}: ${WT}$(printf '%-18s' "$HOST") ${P1}│"
echo -e "${P1} │ ${P3}OS     ${P2}: ${WT}$(printf '%-18s' "$OS") ${P1}│"
echo -e "${P1} │ ${P3}Kernel ${P2}: ${WT}$(printf '%-18s' "$KERNEL") ${P1}│"
echo -e "${P1} │ ${P3}Uptime ${P2}: ${WT}$(printf '%-18s' "$UPTIME") ${P1}│"
echo -e "${P1} ╰──────────────────────────────╯${RS}"
echo ""
EOF
chmod +x "$INSTALL_DIR/banner.sh"

# --- 6. SECURITY GUARD BOT (Compatible with Info above) ---
cat > "$INSTALL_DIR/bin/guard.sh" <<'EOF'
#!/bin/bash
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'
echo -e "${CYAN}[*] NEBULA GUARD: SCANNING...${NC}"
echo "---------------------------------"
# 1. Cek Port
PORTS=$(netstat -tulpn 2>/dev/null | grep -E ":4444|:5555|:1337")
if [ ! -z "$PORTS" ]; then echo -e "${RED}[!] PORT BERBAHAYA:${NC}\n$PORTS"; else echo -e "${GREEN}[OK] Port aman.${NC}"; fi
# 2. Cek File Hidden Script
HIDDEN=$(find . -maxdepth 2 -name ".*.sh" 2>/dev/null)
if [ ! -z "$HIDDEN" ]; then echo -e "${RED}[!] HIDDEN SCRIPT:${NC}\n$HIDDEN"; else echo -e "${GREEN}[OK] File aman.${NC}"; fi
# 3. Cek Malware Signature
grep -rE "rm -rf /|nc -e|bash -i" . --include=*.sh --exclude-dir=.* 2>/dev/null > sr.txt
if [ -s sr.txt ]; then echo -e "${RED}[!] MALWARE DETECTED:${NC}"; cat sr.txt; else echo -e "${GREEN}[OK] Signature bersih.${NC}"; fi
rm sr.txt
echo "---------------------------------"
EOF
chmod +x "$INSTALL_DIR/bin/guard.sh"

# --- 7. TEMA & CONFIG (Adjusted for OS) ---
cat > "$INSTALL_DIR/nebulaX.zsh-theme" <<EOF
P_DARK='%F{093}'
P_MID='%F{129}'
P_LIGHT='%F{213}'
P_CYAN='%F{051}'
RESET='%f'
setopt prompt_subst
function git_stat() {
  ref=\$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "\${P_LIGHT}(\${ref#refs/heads/})\${RESET}"
}
PROMPT="\${P_DARK}╭─\${P_MID}[\${P_CYAN}%~\${P_MID}] \$(git_stat)
\${P_DARK}╰─\${P_LIGHT}🚀 \${RESET}"
RPROMPT="\${P_DARK}%t\${RESET}"
EOF

# Backup .zshrc
if [ -f "$HOME/.zshrc" ]; then cp "$HOME/.zshrc" "$HOME/.zshrc.backup_nebulaX"; fi

# Generate .zshrc
cat > "$HOME/.zshrc" <<EOF
# --- NEBULA-X UNIVERSAL CONFIG ---
bash $INSTALL_DIR/banner.sh

# Core
HISTFILE=\$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
export PATH=\$PATH:$INSTALL_DIR/bin

# Plugins
source $INSTALL_DIR/nebulaX.zsh-theme
fpath=($INSTALL_DIR/plugins/zsh-completions/src \$fpath)
source $INSTALL_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $INSTALL_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $INSTALL_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Keybinds
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "\${(s.:.)LS_COLORS}"

# --- SMART ALIASES ---
alias c='clear'
alias q='exit'
alias scan='bash $INSTALL_DIR/bin/guard.sh'
alias ll='ls -l'

# Detect Package Manager for 'install' alias
if [ -f /data/data/com.termux/files/usr/bin/bash ]; then
    alias install='pkg install'
    alias update='pkg update && pkg upgrade'
elif [ -f /etc/arch-release ]; then
    alias install='sudo pacman -S'
    alias update='sudo pacman -Syu'
elif [ -f /etc/debian_version ]; then
    alias install='sudo apt install'
    alias update='sudo apt update && sudo apt upgrade'
fi

# Helpers
x() {
    if [ -f \$1 ] ; then
        case \$1 in
            *.tar.bz2)   tar xjf \$1     ;;
            *.tar.gz)    tar xzf \$1     ;;
            *.zip)       unzip \$1       ;;
            *)           echo "Unknown" ;;
        esac
    else echo "Missing file"; fi
}
mkcd() { mkdir -p "\$1" && cd "\$1"; }
calc() { echo "\$*" | bc -l; }
EOF

# --- 8. FINISHING ---
chsh -s zsh
echo -e "${GREEN}"
echo "========================================"
echo "    NEBULA-X v5 BERHASIL DIINSTALL!     "
echo "    Layout: Vertical (Art -> Box)       "
echo "    OS Detected: $OS_TYPE               "
echo "    Ketik 'zsh' untuk mulai.            "
echo "========================================"
echo -e "${NC}"
