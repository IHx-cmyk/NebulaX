#!/bin/bash

# --- WARNA PALET UNGU NEBULA ---
C_BORDER='\033[38;5;93m'   # Ungu Gelap (Border)
C_TITLE='\033[38;5;129m'   # Ungu Judul
C_LABEL='\033[38;5;141m'   # Ungu Label Info
C_VALUE='\033[38;5;255m'   # Putih (Isi Info)
C_BAR_ON='\033[38;5;213m'  # Pink/Ungu (Bar Penuh)
C_BAR_OFF='\033[38;5;236m' # Abu Gelap (Bar Kosong)
NC='\033[0m'

clear
echo -e "${C_TITLE}"
echo "========================================"
echo "   NEBULAX | ULTIMATE FULL WIDTH "
echo "========================================"
echo -e "${NC}"

# --- BAGIAN 1: NEUTRALIZE RIVALS ---
echo -e "${C_LABEL}[*] Mengamankan Shell Lain...${NC}"
if [ -d "$HOME/.config/fish" ]; then
    mv "$HOME/.config/fish" "$HOME/.config/fish.old.nebula"
fi
if [ -d "$HOME/.oh-my-zsh" ]; then
    mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.old.nebula"
fi
if [ -f "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup_pre_nebulax"
fi

# --- BAGIAN 2: INSTALL DEPENDENCIES ---
echo -e "${C_LABEL}[*] Menginstall Core System...${NC}"
if [ -f /data/data/com.termux/files/usr/bin/bash ]; then
    PKG_MAN="pkg install -y"
elif [ -f /etc/debian_version ]; then
    PKG_MAN="sudo apt install -y"
else
    PKG_MAN="pkg install -y"
fi

$PKG_MAN zsh git curl wget tar unzip unrar grep bc net-tools

# --- BAGIAN 3: SETUP DIR ---
INSTALL_DIR="$HOME/.nebulaX"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/plugins"
mkdir -p "$INSTALL_DIR/bin"

# --- BAGIAN 4: PLUGINS ---
echo -e "${C_LABEL}[*] Download Plugins...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions "$INSTALL_DIR/plugins/zsh-autosuggestions" --depth 1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$INSTALL_DIR/plugins/zsh-syntax-highlighting" --depth 1
git clone https://github.com/zsh-users/zsh-completions "$INSTALL_DIR/plugins/zsh-completions" --depth 1
git clone https://github.com/zsh-users/zsh-history-substring-search "$INSTALL_DIR/plugins/zsh-history-substring-search" --depth 1

# --- BAGIAN 5: BANNER FULL WIDTH ---
echo -e "${C_LABEL}[*] Membuat Banner Full Screen...${NC}"
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

# --- GET SCREEN SIZE ---
COLS=$(tput cols)
if [ -z "$COLS" ] || [ "$COLS" -lt 10 ]; then COLS=50; fi

# Lebar area dalam box (Total - 2 char border)
WIDTH=$((COLS - 2))

# --- HELPER FUNCTIONS ---

# 1. Print Garis Horizontal Penuh
print_line() {
    # Membuat string dash sepanjang WIDTH
    local dash_line=$(printf '%*s' "$WIDTH" | tr ' ' '─')
    echo -e "${C_BORDER}╭${dash_line}╮${RS}"
}

print_bottom() {
    local text=" [!] NebulaX Protected "
    local text_len=${#text}
    local line_len=$((WIDTH - text_len))
    local left_len=$((line_len / 2))
    local right_len=$((line_len - left_len))
    
    local left_dash=$(printf '%*s' "$left_len" | tr ' ' '─')
    local right_dash=$(printf '%*s' "$right_len" | tr ' ' '─')
    
    echo -e "${C_BORDER}╰${left_dash}${C_LBL}${text}${C_BORDER}${right_dash}╯${RS}"
}

print_mid_line() {
     local dash_line=$(printf '%*s' "$WIDTH" | tr ' ' '─')
     echo -e "${C_BORDER}├${dash_line}┤${RS}"
}

# 2. Print Header dengan Judul di Tengah
print_header() {
    local title=" System "
    local title_len=${#title}
    local line_len=$((WIDTH - title_len))
    local left_len=$((line_len / 2))
    local right_len=$((line_len - left_len))
    
    local left_dash=$(printf '%*s' "$left_len" | tr ' ' '─')
    local right_dash=$(printf '%*s' "$right_len" | tr ' ' '─')
    
    echo -e "${C_BORDER}╭${left_dash}${C_TITLE}${title}${C_BORDER}${right_dash}╮${RS}"
}

# 3. Print Row (Left Text ...... Right Text)
print_row() {
    local key1="$1"
    local val1="$2"
    local key2="$3"
    local val2="$4"
    
    # Hitung panjang teks tanpa warna (approx)
    local len1=$(( ${#key1} + ${#val1} + 1 )) # +1 space
    local len2=$(( ${#key2} + ${#val2} + 1 ))
    
    # Hitung spasi tengah
    local spaces=$((WIDTH - len1 - len2 - 4)) # -4 padding
    if [ $spaces -lt 1 ]; then spaces=1; fi
    local space_str=$(printf '%*s' "$spaces" "")
    
    echo -e "${C_BORDER}│ ${C_LBL}${key1} ${C_VAL}${val1}${space_str} ${C_LBL}${key2} ${C_VAL}${val2} ${C_BORDER}│${RS}"
}

# 4. Print Bar Full Width
print_bar_row() {
    local label="$1"
    local perc="$2"
    local text_val="$3" # e.g. 2GB/4GB
    
    # Hitung lebar bar yang tersedia
    # Format: │ Label [BAR........] Perc │
    # Margin kiri 1, Label, Spasi 1, Bar, Spasi 1, Perc, Margin Kanan 1
    local label_len=${#label}
    local perc_len=${#perc}
    local static_len=$((label_len + perc_len + 6)) # borders & brackets
    local bar_width=$((WIDTH - static_len))
    
    if [ $bar_width -lt 5 ]; then bar_width=5; fi
    
    local filled=$(( (perc * bar_width) / 100 ))
    local empty=$((bar_width - filled))
    
    # Buat visual bar
    local bar_viz=""
    if [ $filled -gt 0 ]; then
        bar_viz+="${C_BAR}"
        bar_viz+=$(printf '%*s' "$filled" | tr ' ' '█')
    fi
    bar_viz+="${C_OFF}"
    bar_viz+=$(printf '%*s' "$empty" | tr ' ' '▒')
    
    echo -e "${C_BORDER}│ ${C_LBL}${label} ${RS}[${bar_viz}${RS}] ${C_VAL}${perc}% ${C_BORDER}│${RS}"
    
    # Subtext (Value Detail) - Centered under the bar roughly
    # Biar simpel, align left agak menjorok
    echo -e "${C_BORDER}│ $(printf '%*s' "$((label_len+2))" "") ${C_OFF}${text_val} ${RS}$(printf '%*s' "$((WIDTH - label_len - ${#text_val} - 4))" "") ${C_BORDER}│${RS}"
}


# --- GATHER INFO ---
USER=$(whoami)
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
SHELL_NAME=${SHELL##*/}
KERNEL=$(uname -r | cut -d'-' -f1)

# RAM
if [ -f /proc/meminfo ]; then
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    if [ -z "$MEM_FREE" ]; then MEM_FREE=$(grep MemFree /proc/meminfo | awk '{print $2}'); fi
    MEM_USED=$((MEM_TOTAL - MEM_FREE))
    MEM_PERC=$(( (MEM_USED * 100) / MEM_TOTAL ))
    MEM_TXT="$(echo "scale=1; $MEM_USED/1024/1024" | bc)G / $(echo "scale=1; $MEM_TOTAL/1024/1024" | bc)G"
else
    MEM_PERC=0
    MEM_TXT="?"
fi

# DISK
DISK_PERC=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_TXT="$(df -h / | awk 'NR==2 {print $3}') / $(df -h / | awk 'NR==2 {print $2}')"

# --- RENDER ---
clear
echo ""

# 1. PLANET CENTERED
pad=$(( (COLS - 30) / 2 ))
if [ $pad -lt 0 ]; then pad=0; fi
P_PAD=$(printf '%*s' "$pad" "")

echo -e "${P_PAD}${C_BORDER}         ,MMM8&&&.            "
echo -e "${P_PAD}${C_BORDER}    _MMMMMMM888888&.          "
echo -e "${P_PAD}${C_BORDER}  MMMMMM88888888888&          "
echo -e "${P_PAD}${C_BORDER}  MMMMMM888888888888          "
echo -e "${P_PAD}${C_BORDER}   \`MMMM88888888888'          "
echo -e "${P_PAD}${C_BORDER}       \`YMM8888888'           "
echo -e "${P_PAD}${C_BORDER}         \`\"\"\"\"\"\"'             "
echo ""

# 2. BOX FULL WIDTH
print_header
print_row "User" "$USER" "Time" "$TIME"
print_row "Date" "$DATE" "Shell" "$SHELL_NAME"
print_row "OS" "Android" "Kern" "${KERNEL:0:10}"
print_mid_line
print_bar_row "RAM " "$MEM_PERC" "$MEM_TXT"
print_bar_row "Disk" "$DISK_PERC" "$DISK_TXT"
print_bottom
echo ""
EOF
chmod +x "$INSTALL_DIR/banner.sh"

# --- BAGIAN 6: SECURITY BOT ---
cat > "$INSTALL_DIR/bin/guard.sh" <<'EOF'
#!/bin/bash
echo "Scanning..."
netstat -tulpn 2>/dev/null | grep -E ":4444|:5555" && echo "PORT BAHAYA DETECTED!"
find . -maxdepth 2 -name ".*.sh" && echo "HIDDEN SCRIPT DETECTED!"
EOF
chmod +x "$INSTALL_DIR/bin/guard.sh"

# --- BAGIAN 7: THEMA ---
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

chsh -s zsh
echo -e "${C_TITLE}INSTALASI SELESAI.${NC}"
echo -e "${C_LABEL}Ketik 'zsh' untuk melihat Banner Full Width.${NC}"
