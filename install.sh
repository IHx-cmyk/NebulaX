#!/bin/bash

# --- WARNA PALET UNGU NEBULA ---
# Menggunakan kode ANSI 256 untuk presisi warna
C_BORDER='\033[38;5;93m'   # Ungu Gelap (Border)
C_TITLE='\033[38;5;129m'  # Ungu Judul
C_LABEL='\033[38;5;141m'  # Ungu Label Info
C_VALUE='\033[38;5;255m'  # Putih (Isi Info)
C_BAR_ON='\033[38;5;213m' # Pink/Ungu (Bar Penuh)
C_BAR_OFF='\033[38;5;236m' # Abu Gelap (Bar Kosong)
NC='\033[0m'

clear
echo -e "${C_TITLE}"
echo "========================================"
echo "   NEBULAX | ULTIMATE "
echo "========================================"
echo -e "${NC}"

# --- BAGIAN 1: NEUTRALIZE RIVALS (MATIKAN TEMA LAIN) ---
echo -e "${C_LABEL}[*] Mendeteksi & Mengamankan Shell Lain...${NC}"

# 1. Matikan Fish
if [ -d "$HOME/.config/fish" ]; then
    mv "$HOME/.config/fish" "$HOME/.config/fish.old.nebula"
    echo -e "${C_BORDER}    -> Konfigurasi Fish dinonaktifkan (Backup: fish.old.nebula)${NC}"
fi

# 2. Matikan Oh-My-Zsh atau Zsh lama
if [ -d "$HOME/.oh-my-zsh" ]; then
    mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.old.nebula"
    echo -e "${C_BORDER}    -> Oh-My-Zsh dinonaktifkan.${NC}"
fi

# 3. Backup .zshrc lama
if [ -f "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup_pre_nebulax"
    echo -e "${C_BORDER}    -> .zshrc lama diamankan.${NC}"
fi

# --- BAGIAN 2: INSTALL DEPENDENCIES ---
echo -e "${C_LABEL}[*] Menginstall Core System...${NC}"

# Deteksi Package Manager
if [ -f /data/data/com.termux/files/usr/bin/bash ]; then
    PKG_MAN="pkg install -y"
    OS_TAG="Android"
elif [ -f /etc/debian_version ]; then
    PKG_MAN="sudo apt install -y"
    OS_TAG="Linux"
elif [ -f /etc/arch-release ]; then
    PKG_MAN="sudo pacman -S --noconfirm"
    OS_TAG="Linux"
else
    PKG_MAN="pkg install -y"
fi

$PKG_MAN zsh git curl wget tar unzip unrar grep bc net-tools

# --- BAGIAN 3: SETUP NEBULAX DIR ---
INSTALL_DIR="$HOME/.nebulaX"
if [ -d "$INSTALL_DIR" ]; then rm -rf "$INSTALL_DIR"; fi
mkdir -p "$INSTALL_DIR/plugins"
mkdir -p "$INSTALL_DIR/bin"

# --- BAGIAN 4: PLUGINS ---
echo -e "${C_LABEL}[*] Download Plugins...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions "$INSTALL_DIR/plugins/zsh-autosuggestions" --depth 1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$INSTALL_DIR/plugins/zsh-syntax-highlighting" --depth 1
git clone https://github.com/zsh-users/zsh-completions "$INSTALL_DIR/plugins/zsh-completions" --depth 1
git clone https://github.com/zsh-users/zsh-history-substring-search "$INSTALL_DIR/plugins/zsh-history-substring-search" --depth 1

# --- BAGIAN 5: BANNER STELLAR (CENTERED LOGIC) ---
echo -e "${C_LABEL}[*] Membuat Banner Stellar Center...${NC}"
cat > "$INSTALL_DIR/banner.sh" <<'EOF'
#!/bin/bash

# --- WARNA ---
C_BORDER='\033[38;5;93m'
C_TITLE='\033[38;5;213m'
C_LBL='\033[38;5;141m'
C_VAL='\033[38;5;255m'
C_BAR='\033[38;5;129m'
C_OFF='\033[38;5;236m'
RS='\033[0m'

# --- FUNGSI TENGAH (CENTER) ---
print_center() {
    local text="$1"
    local cols=$(tput cols)
    local len=${#text}
    # Hapus kode warna untuk hitung panjang asli
    local clean_text=$(echo -e "$text" | sed "s/\x1B\[[0-9;]*[a-zA-Z]//g")
    local clean_len=${#clean_text}
    
    local pad=$(( (cols - clean_len) / 2 ))
    if [ $pad -lt 0 ]; then pad=0; fi
    printf "%${pad}s" " "
    echo -e "$text"
}

# --- INFO SYSTEM ---
USER=$(whoami)
HOST=$(hostname)
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
SHELL_NAME=${SHELL##*/}
KERNEL=$(uname -r | cut -d'-' -f1)

if grep -q "Termux" /data/data/com.termux/files/usr/bin/login 2>/dev/null; then
    OS="Android Termux"
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    OS=$(uname -o)
fi

# RAM & DISK BAR CALCULATION
# (Simple logic for Termux/Linux)
if [ -f /proc/meminfo ]; then
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    if [ -z "$MEM_FREE" ]; then MEM_FREE=$(grep MemFree /proc/meminfo | awk '{print $2}'); fi
    MEM_USED=$((MEM_TOTAL - MEM_FREE))
    MEM_PERC=$(( (MEM_USED * 100) / MEM_TOTAL ))
    
    # Convert to GB/MB
    MEM_TXT_USED=$(echo "scale=2; $MEM_USED/1024/1024" | bc)
    MEM_TXT_TOTAL=$(echo "scale=2; $MEM_TOTAL/1024/1024" | bc)
else
    MEM_PERC=50
    MEM_TXT_USED="?"
    MEM_TXT_TOTAL="?"
fi

# DISK
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_PERC=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

# Draw Bar Function
draw_bar() {
    local perc=$1
    local width=15
    local filled=$(( (perc * width) / 100 ))
    local empty=$(( width - filled ))
    
    printf "${C_BAR}"
    for ((i=0; i<filled; i++)); do printf "█"; done
    printf "${C_OFF}"
    for ((i=0; i<empty; i++)); do printf "▒"; done
    printf "${RS}"
}

RAM_BAR=$(draw_bar $MEM_PERC)
DISK_BAR=$(draw_bar $DISK_PERC)

# --- ART & BOX ---
clear
echo ""

# 1. PLANET ASCII (CENTERED)
# Planet ini mirip Saturnus
print_center "${C_BORDER}         ,MMM8&&&.            "
print_center "${C_BORDER}    _MMMMMMM888888&.          "
print_center "${C_BORDER}  MMMMMM88888888888&          "
print_center "${C_BORDER}  MMMMMM888888888888          "
print_center "${C_BORDER}   \`MMMM88888888888'          "
print_center "${C_BORDER}       \`YMM8888888'           "
print_center "${C_BORDER}         \`\"\"\"\"\"\"'             "
echo ""

# 2. BOX INFO (CENTERED BLOCK)
# Kita bangun boxnya dulu dalam variabel, lalu print_center per baris
# Format Box 

L="${C_BORDER}│${RS}" # Garis kiri kanan
# Lebar konten sekitar 50 char

# Top Border dengan Judul "Sistema"
line1="${C_BORDER}╭──────────── ${C_TITLE}System${C_BORDER} ────────────╮${RS}"
print_center "$line1"

# Isi Box
# Baris 1: User & Time
str=$(printf "${L} ${C_LBL}Usually ${C_VAL}%-10s   ${C_LBL}Time ${C_VAL}%-8s ${L}" "$USER" "$TIME")
print_center "$str"

# Baris 2: Date & Shell
str=$(printf "${L} ${C_LBL}Date   ${C_VAL}%-10s   ${C_LBL}Shell ${C_VAL}%-7s  ${L}" "$DATE" "$SHELL_NAME")
print_center "$str"

# Baris 3: System & Kernel
str=$(printf "${L} ${C_LBL}OS      ${C_VAL}%-10s   ${C_LBL}Kern  ${C_VAL}%-7s  ${L}" "${OS:0:10}" "${KERNEL:0:7}")
print_center "$str"

# Divider Tipis
print_center "${C_BORDER}├─────────────────────────────────┤${RS}"

# Baris RAM
str=$(printf "${L} ${C_LBL}RAM   ${RS}%s ${C_VAL}%3s%%           ${L}" "$RAM_BAR" "$MEM_PERC")
print_center "$str"
str=$(printf "${L}       ${C_OFF}${MEM_TXT_USED}GB / ${MEM_TXT_TOTAL}GB${RS}                ${L}")
print_center "$str"

# Baris DISK
str=$(printf "${L} ${C_LBL}Disk  ${RS}%s ${C_VAL}%3s%%           ${L}" "$DISK_BAR" "$DISK_PERC")
print_center "$str"
str=$(printf "${L}       ${C_OFF}${DISK_USED} / ${DISK_TOTAL}${RS}                     ${L}")
print_center "$str"

# Bottom Border (IP De ToR style footer)
line_end="${C_BORDER}╰────── ${C_LBL}[!] ${C_VAL}Nebula${C_TITLE}X ${C_LBL}Protected ${C_BORDER}─────╯${RS}"
print_center "$line_end"
echo ""
EOF
chmod +x "$INSTALL_DIR/banner.sh"

# --- BAGIAN 6: SECURITY BOT ---
cat > "$INSTALL_DIR/bin/guard.sh" <<'EOF'
#!/bin/bash
# (Bot Security Standar NebulaX)
echo "Scanning..."
netstat -tulpn 2>/dev/null | grep -E ":4444|:5555" && echo "PORT BAHAYA DETECTED!"
find . -maxdepth 2 -name ".*.sh" && echo "HIDDEN SCRIPT DETECTED!"
EOF
chmod +x "$INSTALL_DIR/bin/guard.sh"

# --- BAGIAN 7: THEMA & ZSHRC ---
cat > "$INSTALL_DIR/nebulaX.zsh-theme" <<EOF
P_1='%F{093}'
P_2='%F{129}'
P_3='%F{213}'
RESET='%f'
setopt prompt_subst
function git_stat() {
  ref=\$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "\${P_3}(\${ref#refs/heads/})\${RESET}"
}
# Prompt Simpel Elegan
PROMPT="\${P_1}┌──\${P_2}[\${P_3}%~\${P_2}] \$(git_stat)
\${P_1}└─\${P_3}😈 \${RESET}"
EOF

cat > "$HOME/.zshrc" <<EOF
# --- NEBULA-X CONFIG ---
bash $INSTALL_DIR/banner.sh

HISTFILE=\$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

export PATH=\$PATH:$INSTALL_DIR/bin

source $INSTALL_DIR/nebulaX.zsh-theme
fpath=($INSTALL_DIR/plugins/zsh-completions/src \$fpath)
source $INSTALL_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $INSTALL_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $INSTALL_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "\${(s.:.)LS_COLORS}"

alias c='clear'
alias scan='bash $INSTALL_DIR/bin/guard.sh'
alias install='$PKG_MAN'
EOF

# --- BAGIAN 8: FINALISASI ---
chsh -s zsh
echo -e "${C_TITLE}INSTALASI SELESAI.${NC}"
echo -e "${C_LABEL}Silakan ketik 'zsh' atau restart terminal.${NC}"
