#!/data/data/com.termux/files/usr/bin/bash

# --- WARNA INSTALLER ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

clear
echo -e "${PURPLE}"
echo "========================================"
echo " N E B U L A - X | FORTRESS EDITION v4"
echo "========================================"
echo -e "${NC}"

# 1. Update & Install Dependencies (Tambah nmap & clamav dependencies opsional)
echo -e "${CYAN}[*] Menyiapkan environment & tools security...${NC}"
pkg update -y && pkg upgrade -y
pkg install zsh git curl wget tar unzip unrar grep bc net-tools procps -y

# 2. Setup Folder
INSTALL_DIR="$HOME/.nebulaX"
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${PURPLE}[*] Versi lama terdeteksi, upgrade sistem...${NC}"
fi
mkdir -p "$INSTALL_DIR/plugins"
mkdir -p "$INSTALL_DIR/bin"

# 3. Download Plugin ZSH
echo -e "${CYAN}[*] Mendownload Plugin ZSH...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions "$INSTALL_DIR/plugins/zsh-autosuggestions" --depth 1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$INSTALL_DIR/plugins/zsh-syntax-highlighting" --depth 1
git clone https://github.com/zsh-users/zsh-completions "$INSTALL_DIR/plugins/zsh-completions" --depth 1
git clone https://github.com/zsh-users/zsh-history-substring-search "$INSTALL_DIR/plugins/zsh-history-substring-search" --depth 1

# 4. Membuat Banner Boxed (Kotak)
echo -e "${CYAN}[*] Membuat Visual Box System...${NC}"
cat > "$INSTALL_DIR/banner.sh" <<'EOF'
#!/bin/bash
P1='\e[38;5;93m'   # Dark Purple
P2='\e[38;5;129m'  # Mid Purple
P3='\e[38;5;141m'  # Light Purple
P4='\e[38;5;213m'  # Pink Neon
WT='\e[38;5;255m'  # White
RS='\e[0m'

# Info Gather
USER=$(whoami)
HOST=$(hostname)
OS="Android/Termux"
if [ -f /etc/os-release ]; then . /etc/os-release; OS=$NAME; fi
KERNEL=$(uname -r | cut -d'-' -f1)
# Memory usage simple calc
MEM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

# ASCII ART (Simpel biar muat di sebelah box)
read -r -d '' LOGO << EOM
${P1}  ▄▄▄▄▄
${P1} █${P2}█████${P1}█
${P1}█${P2}█${WT} █ ${P2}█${P1}██
${P1}█${P2}██▀▀▀██${P1}
${P1} ▀   ▀
EOM

# BOX DRAWING
# Kita pakai printf formatting untuk meratakan isi box
line1="${P2}╭─ SYSTEM INFO ─────────────╮"
line2="${P2}│ ${P3}User  ${P2}: ${WT}%-16s${P2}│"
line3="${P2}│ ${P3}OS    ${P2}: ${WT}%-16s${P2}│"
line4="${P2}│ ${P3}Kernel${P2}: ${WT}%-16s${P2}│"
line5="${P2}│ ${P3}Ram   ${P2}: ${WT}%-16s${P2}│"
line6="${P2}╰───────────────────────────╯"

# Print Side by Side (Logo kiri, Box kanan)
clear
echo ""
printf "${P1}      ${line1}\n"
printf "${P1}  ▄▄▄ ${P1}$(printf "$line2" "$USER")\n"
printf "${P1} █${P2}█${P1}█ ${P1}$(printf "$line3" "$OS")\n"
printf "${P1} █${P2}▀${P1}█ ${P1}$(printf "$line4" "$KERNEL")\n"
printf "${P1}  ▀▀▀ ${P1}$(printf "$line5" "$MEM")\n"
printf "${P1}      ${line6}\n"
echo -e "       ${P4}Hecho en NebulaX ${RS}\n"
EOF

# 5. Membuat "NebulaGuard" (Bot Security Scanner)
echo -e "${CYAN}[*] Menginstall NebulaGuard Security Bot...${NC}"
cat > "$INSTALL_DIR/bin/guard.sh" <<'EOF'
#!/bin/bash
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

echo -e "${CYAN}[*] NEBULA-GUARD: Memulai Scanning Sistem...${NC}"
echo "----------------------------------------------"

# 1. Cek Port Berbahaya (RAT/Metasploit defaults)
echo -e "${YELLOW}[?] Memeriksa Port Terbuka...${NC}"
PORTS=$(netstat -tulpn 2>/dev/null | grep -E ":4444|:5555|:6666|:1337")
if [ ! -z "$PORTS" ]; then
    echo -e "${RED}[!] BAHAYA! Port mencurigakan ditemukan:${NC}"
    echo "$PORTS"
else
    echo -e "${GREEN}[OK] Tidak ada port RAT standar yang aktif.${NC}"
fi

# 2. Cari File Script Mencurigakan (Hidden .sh)
echo -e "${YELLOW}[?] Mencari script tersembunyi...${NC}"
HIDDEN=$(find . -maxdepth 2 -name ".*.sh" 2>/dev/null)
if [ ! -z "$HIDDEN" ]; then
    echo -e "${RED}[!] Script tersembunyi ditemukan (Cek manual):${NC}"
    echo "$HIDDEN"
else
    echo -e "${GREEN}[OK] Bersih.${NC}"
fi

# 3. Cek Permission 777 (World Writable berbahaya)
echo -e "${YELLOW}[?] Mencari file permission 777 (Rawan)...${NC}"
WW=$(find . -maxdepth 2 -type f -perm 777 2>/dev/null)
if [ ! -z "$WW" ]; then
    echo -e "${RED}[!] File dengan akses penuh ditemukan:${NC}"
    echo "$WW"
else
    echo -e "${GREEN}[OK] Permission aman.${NC}"
fi

# 4. Keyword Scanning (payloads)
echo -e "${YELLOW}[?] Scanning konten file untuk signature virus...${NC}"
# Cari kata 'rm -rf /', 'mkfifo', 'nc -e' di file .sh
grep -rE "rm -rf /|nc -e|bash -i" . --include=*.sh --exclude-dir=.* 2>/dev/null > scan_result.txt
if [ -s scan_result.txt ]; then
    echo -e "${RED}[!] POTENSI MALWARE DI SKRIP LOKAL:${NC}"
    cat scan_result.txt
    rm scan_result.txt
else
    echo -e "${GREEN}[OK] Signature bersih.${NC}"
    rm scan_result.txt
fi

echo "----------------------------------------------"
echo -e "${CYAN}Scan Selesai.${NC}"
EOF
chmod +x "$INSTALL_DIR/bin/guard.sh"

# 6. Setup Tema (Sama seperti v3 tapi dioptimalkan)
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
\${P_DARK}╰─\${P_LIGHT}🤖 \${RESET}"
RPROMPT="\${P_DARK}%t\${RESET}"
EOF

# 7. Membuat MEGA HELPER .zshrc
echo -e "${CYAN}[*] Menyuntikkan helper functions...${NC}"
if [ -f "$HOME/.zshrc" ]; then cp "$HOME/.zshrc" "$HOME/.zshrc.backup_nebulaX"; fi

cat > "$HOME/.zshrc" <<EOF
# --- NEBULA-X FORTRESS CONFIG ---

# 1. Startup Banner
bash $INSTALL_DIR/banner.sh

# 2. Core Settings
HISTFILE=\$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
export PATH=\$PATH:$INSTALL_DIR/bin

# 3. Load Plugin & Theme
source $INSTALL_DIR/nebulaX.zsh-theme
fpath=($INSTALL_DIR/plugins/zsh-completions/src \$fpath)
source $INSTALL_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $INSTALL_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $INSTALL_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# 4. Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "\${(s.:.)LS_COLORS}"

# --- 5. MEGA HELPERS & ALIASES ---

# > SYSTEM
alias c='clear'
alias q='exit'
alias refresh='source ~/.zshrc && echo "Config Reloaded!"'
alias mem='free -h'
alias space='df -h'
alias install='pkg install'
alias update='pkg update && pkg upgrade'

# > SECURITY BOT
alias scan='bash $INSTALL_DIR/bin/guard.sh'  # <--- INI BOT NYA
alias ports='netstat -tulpn'
alias myip='curl ifconfig.me'

# > NAVIGATION
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -l'
alias la='ls -la'
mkcd() { mkdir -p "\$1" && cd "\$1"; }

# > FILE MANAGEMENT
# Extract file apa aja otomatis
x() {
    if [ -f \$1 ] ; then
        case \$1 in
            *.tar.bz2)   tar xjf \$1     ;;
            *.tar.gz)    tar xzf \$1     ;;
            *.rar)       unrar e \$1     ;;
            *.zip)       unzip \$1       ;;
            *)           echo "Unknown format" ;;
        esac
    else echo "File not found"; fi
}

# > TOOLS
# Cuaca hari ini
alias weather='curl wttr.in/Indonesia'
# Cari file besar (Top 5 terbesar di folder ini)
alias bigfiles='du -ah . | sort -rh | head -5'
# Kalkulator cepat (contoh: calc 5*20)
calc() { echo "\$*" | bc -l; }

# Safety
alias rm='rm -i'
alias cp='cp -i'

EOF

# 8. Ganti Shell
chsh -s zsh

echo -e "${GREEN}"
echo "========================================"
echo " NEBULA-X SIAP DIGUNAKAN!               "
echo " Ketik 'scan' untuk cek virus/malware.  "
echo "========================================"
echo -e "${NC}"
