#!/usr/bin/env bash

# =============================================================================
#   nebulaX - Ultimate Terminal Experience (Termux / Linux / macOS / WSL)
#   Inspired by style like Stellar, but full-width cosmic nebula theme
# =============================================================================

# ─── Warna Palet Nebula (256 colors) ────────────────────────────────────────
C_BORDER='\033[38;5;93m'     # Ungu gelap border
C_TITLE='\033[38;5;129m'     # Ungu mid judul
C_ACCENT='\033[38;5;165m'    # Magenta accent
C_HL='\033[38;5;213m'        # Pink cerah (highlight & bar)
C_LABEL='\033[38;5;147m'     # Ungu muda label
C_VALUE='\033[38;5;231m'     # Putih cerah value
C_BAR_ON='\033[38;5;213m'    # Pink bar penuh
C_BAR_OFF='\033[38;5;237m'   # Abu sangat gelap bar kosong
NC='\033[0m'

clear
echo -e "${C_TITLE}"
printf '═%.0s' $(seq 1 $(tput cols 2>/dev/null || echo 80))
echo -e "              nebulaX  •  ULTIMATE TERMINAL SUITE${NC}"
printf '─%.0s' $(seq 1 $(tput cols 2>/dev/null || echo 80))
echo -e "${NC}"

# ─── 1. Neutralisasi pesaing (backup dulu) ──────────────────────────────────
echo -e "\( {C_LABEL}→ Mengamankan konfigurasi shell lain... \){NC}"
[ -d "$HOME/.config/fish" ]     && mv "$HOME/.config/fish"     "$HOME/.config/fish.bak.nebulaX"     2>/dev/null
[ -d "$HOME/.oh-my-zsh" ]       && mv "$HOME/.oh-my-zsh"       "$HOME/.oh-my-zsh.bak.nebulaX"       2>/dev/null
[ -f "$HOME/.zshrc" ]           && mv "$HOME/.zshrc"           "$HOME/.zshrc.bak.pre-nebulaX"       2>/dev/null
[ -f "$HOME/.zprofile" ]        && mv "$HOME/.zprofile"        "$HOME/.zprofile.bak.pre-nebulaX"    2>/dev/null

# ─── 2. Deteksi OS & Package Manager ────────────────────────────────────────
echo -e "\( {C_LABEL}→ Mendeteksi sistem & menyiapkan package manager... \){NC}"

if [[ -f /data/data/com.termux/files/usr/bin/bash ]]; then
    OS_TYPE="termux"
    PKG_INSTALL="pkg install -y"
    PKG_UPDATE="pkg update -y && pkg upgrade -y"
elif [[ -f /etc/debian_version ]] || grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
    OS_TYPE="debian"
    PKG_INSTALL="sudo apt update -y && sudo apt install -y"
elif [[ -f /etc/fedora-release ]]; then
    OS_TYPE="fedora"
    PKG_INSTALL="sudo dnf install -y"
elif [[ "$(uname)" == "Darwin" ]]; then
    OS_TYPE="macos"
    if command -v brew >/dev/null; then
        PKG_INSTALL="brew install"
    else
        echo -e "${C_LABEL}Homebrew tidak ditemukan. Install dulu: /bin/bash -c \"\\( (curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" \){NC}"
        exit 1
    fi
else
    echo -e "\( {C_LABEL}Sistem tidak didukung secara penuh. Menggunakan fallback Termux style. \){NC}"
    PKG_INSTALL="sudo apt install -y || sudo dnf install -y || pkg install -y"
fi

# ─── 3. Install dependensi inti ─────────────────────────────────────────────
echo -e "\( {C_LABEL}→ Menginstall paket yang dibutuhkan... \){NC}"
$PKG_INSTALL zsh git curl wget tar unzip bc coreutils net-tools procps-ng 2>/dev/null || true

# macOS biasanya sudah punya sebagian besar, jadi aman dilewati jika gagal

# ─── 4. Direktori nebulaX ───────────────────────────────────────────────────
INSTALL_DIR="$HOME/.nebulaX"
rm -rf "$INSTALL_DIR" 2>/dev/null
mkdir -p "$INSTALL_DIR"/{plugins,bin,tmp}

# ─── 5. Plugins Zsh populer & berguna ──────────────────────────────────────
echo -e "\( {C_LABEL}→ Mengunduh plugins Zsh... \){NC}"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions         "$INSTALL_DIR/plugins/zsh-autosuggestions"         2>/dev/null
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting     "$INSTALL_DIR/plugins/zsh-syntax-highlighting"     2>/dev/null
git clone --depth 1 https://github.com/zsh-users/zsh-completions             "$INSTALL_DIR/plugins/zsh-completions"             2>/dev/null
git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search "$INSTALL_DIR/plugins/zsh-history-substring-search" 2>/dev/null
git clone --depth 1 https://github.com/romkatv/powerlevel10k.git             "$INSTALL_DIR/plugins/powerlevel10k"               2>/dev/null  # cadangan jika mau ganti theme nanti

# ─── 6. Banner & Info System Full-Width ─────────────────────────────────────
echo -e "\( {C_LABEL}→ Membuat banner cosmic full-width... \){NC}"

cat > "$INSTALL_DIR/banner.sh" <<'EOF'
#!/usr/bin/env bash

# Warna (sama dengan install.sh)
C_BORDER='\033[38;5;93m'; C_TITLE='\033[38;5;129m'; C_HL='\033[38;5;213m'
C_LABEL='\033[38;5;147m'; C_VALUE='\033[38;5;231m'; C_BAR_ON='\033[38;5;213m'
C_BAR_OFF='\033[38;5;237m'; NC='\033[0m'

COLS=$(tput cols 2>/dev/null || echo 80)
(( COLS < 60 )) && COLS=60
WIDTH=$((COLS - 2))

print_full_line() { printf "${C_BORDER}─%.0s" $(seq 1 \( COLS); echo " \){NC}"; }

print_box_top()    { echo -e "\( {C_BORDER}╭ \)(printf '─%.0s' $(seq 1 \( WIDTH))╮ \){NC}"; }
print_box_bottom() { echo -e "\( {C_BORDER}╰ \)(printf '─%.0s' $(seq 1 \( WIDTH))╯ \){NC}"; }
print_box_mid()    { echo -e "\( {C_BORDER}├ \)(printf '─%.0s' $(seq 1 \( WIDTH))┤ \){NC}"; }

print_centered() {
    local text="$1" color="${2:-$C_TITLE}"
    local len=${#text}
    local pad=$(( (WIDTH - len) / 2 ))
    echo -e "\( {C_BORDER}│ \){NC}$(printf ' %.0s' $(seq 1 \( pad)) \){color}\( {text} \){NC}$(printf ' %.0s' $(seq 1 \( ((WIDTH - len - pad)))) \){C_BORDER}│${NC}"
}

print_row() {
    local left="$1" right="$2"
    local l_len=\( {#left} r_len= \){#right}
    local gap=$((WIDTH - l_len - r_len - 4))
    (( gap < 4 )) && gap=4
    echo -e "${C_BORDER}│ \( {C_LABEL} \){left} \( {C_VALUE} \){right}$(printf ' %.0s' $(seq 1 \( gap)) \){C_BORDER}│${NC}"
}

print_bar() {
    local label="$1" perc="$2" detail="$3"
    local lbl_len=${#label}
    local avail=$((WIDTH - lbl_len - ${#perc} - 12))
    (( avail < 10 )) && avail=10

    local fill=$(( (perc * avail) / 100 ))
    local empt=$((avail - fill))

    local bar="\( {C_BAR_ON} \)(printf '█%.0s' $(seq 1 \( fill)) \){C_BAR_OFF}$(printf '▒%.0s' $(seq 1 $empt))"

    echo -e "${C_BORDER}│ \( {C_LABEL} \){label} \( {C_BORDER}[ \){NC}\( {bar} \){C_BORDER}] \( {C_VALUE} \){perc}%${NC} \( {C_BORDER}│ \){NC}"
    [[ -n "\( detail" ]] && echo -e " \){C_BORDER}│ \( {NC} \)(printf ' %.0s' $(seq 1 \( ((lbl_len+2)))) \){C_VALUE}\( {detail} \){NC}$(printf ' %.0s' $(seq 1 $((WIDTH - lbl_len - \( {#detail} - 6)))) \){C_BORDER}│${NC}"
}

# ── Gather Info ──────────────────────────────────────────────────────────────
user=$(whoami)
date=$(date +%Y-%m-%d)
time=$(date +%H:%M:%S)
kernel=$(uname -r | cut -d'.' -f1-2)
shell=${SHELL##*/}

# RAM (cross-platform sebisa mungkin)
if [[ -f /proc/meminfo ]]; then
    total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    free=$(grep MemAvailable /proc/meminfo | awk '{print $2}' || grep MemFree | awk '{print $2}')
    used=$((total - free))
    perc=$(( (used * 100) / total ))
    ram_txt="$(bc <<< "scale=1; $used/1024/1024")G / $(bc <<< "scale=1; $total/1024/1024")G"
else
    perc=0; ram_txt="n/a"
fi

# Disk root
disk_perc=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%' || echo "n/a")
disk_txt=$(df -h / 2>/dev/null | awk 'NR==2 {print $3" / "$2}' || echo "n/a")

clear
print_full_line
echo ""
print_centered "   .     .     .     N E B U L A X     .     .     .   " "$C_HL"
echo ""
cat <<'ART' | sed "s/./\( {C_BORDER}& \){NC}/g" | sed "s/^/$(printf ' %.0s' $(seq 1 $(( (COLS-44)/2 ))))/"
       🌌✨      .          .      🌠
     .      .     .     .      .     .
   .    ✧    .      .     .      .     .
      .     .     .     .      .     .
        .      .     .     .      .
ART
echo ""

print_box_top
print_centered " SYSTEM STATUS " "$C_TITLE"
print_box_mid
print_row "User     :" "$user" 
print_row "Date     :" "$date $time"
print_row "Shell    :" "$shell"
print_row "Kernel   :" "$kernel"
print_row "OS       :" "${OS_TYPE^}"
print_box_mid
print_bar "RAM      " "$perc" "$ram_txt"
print_bar "Disk /   " "$disk_perc" "$disk_txt"
print_box_bottom

echo -e "\n\( {C_LABEL}  nebulaX ready • ketik ' \){C_HL}help\( {C_LABEL}' untuk daftar perintah \){NC}\n"
EOF

chmod +x "$INSTALL_DIR/banner.sh"

# ─── 7. Beberapa helper di bin/ ─────────────────────────────────────────────
mkdir -p "$INSTALL_DIR/bin"

cat > "$INSTALL_DIR/bin/help" <<'EOF'
#!/usr/bin/env bash
echo -e "\n\( {C_HL}nebulaX Helpers \){NC}"
echo "──────────────────────────────────────────────"
echo " \( {C_LABEL}scan \){NC}        → cek port mencurigakan & file tersembunyi"
echo " \( {C_LABEL}update \){NC}      → update paket (sesuai OS)"
echo " \( {C_LABEL}weather \){NC}     → cuaca kota (butuh curl)"
echo " \( {C_LABEL}myip \){NC}        → tampilkan IP publik"
echo " \( {C_LABEL}clearcache \){NC}  → bersihkan cache zsh & history"
echo -e "\nTambahkan sendiri di $HOME/.nebulaX/bin/\n"
EOF

cat > "$INSTALL_DIR/bin/scan" <<'EOF'
#!/usr/bin/env bash
echo -e "\( {C_LABEL}Scanning suspicious ports & files... \){NC}"
ss -tulpn 2>/dev/null | grep -E ':(4444|5555|1337|6666|13377)' && echo "\( {C_HL}Dangerous port detected! \){NC}"
find ~ -maxdepth 3 -type f -name ".*.sh" -o -name "*.py" -o -name "*.exe" 2>/dev/null
EOF

cat > "$INSTALL_DIR/bin/myip" <<'EOF'
#!/usr/bin/env bash
curl -s ifconfig.me || curl -s icanhazip.com || echo "Cannot reach IP check service"
EOF

cat > "$INSTALL_DIR/bin/update" <<'EOF'
#!/usr/bin/env bash
if command -v pkg >/dev/null; then pkg update -y && pkg upgrade -y
elif command -v apt >/dev/null; then sudo apt update && sudo apt upgrade -y
elif command -v dnf >/dev/null; then sudo dnf update -y
elif command -v brew >/dev/null; then brew update && brew upgrade
fi
EOF

chmod +x "$INSTALL_DIR/bin/"*

# ─── 8. Tema Prompt sederhana tapi cosmic ───────────────────────────────────
cat > "$INSTALL_DIR/nebulaX.zsh-theme" <<'EOF'
P1='%F{093}' P2='%F{129}' P3='%F{213}' P4='%F{165}' RESET='%f'

git_info() {
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  echo "\( {P4}( \){ref})${RESET}"
}

PS1="\( {P1}┌─ \){P2}[\( {P3}%2~ \){P2}]${RESET} \$(git_info)
\( {P1}└─ \){P3}⋆⁺₊☾⁺₊⋆⁺₊ ${RESET}"
RPROMPT="\( {P4}%* \){RESET}"
EOF

# ─── 9. .zshrc utama ────────────────────────────────────────────────────────
cat > "$HOME/.zshrc" <<EOF
# ─── nebulaX ────────────────────────────────────────────────────────────────
clear && bash $INSTALL_DIR/banner.sh

export PATH="\$PATH:$INSTALL_DIR/bin"

# History
HISTSIZE=20000
SAVEHIST=20000
HISTFILE=\$HOME/.zsh_history
setopt SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY

# Plugins
source $INSTALL_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $INSTALL_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $INSTALL_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Keybinding
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Theme
source $INSTALL_DIR/nebulaX.zsh-theme

# Aliases umum
alias cl='clear'
alias h='help'
alias s='scan'
alias up='update'
alias i='$PKG_INSTALL'
alias weather='curl wttr.in'
alias ll='ls -lah --color=auto'
alias nanozsh='nano ~/.zshrc'

# Supaya langsung kelihatan banner setelah install
EOF

# ─── 10. Ganti shell ke zsh (jika memungkinkan) ─────────────────────────────
if command -v zsh >/dev/null; then
    chsh -s "\( (command -v zsh)" 2>/dev/null || echo -e " \){C_LABEL}chsh gagal. Jalankan 'zsh' secara manual.${NC}"
fi

echo -e "\n\( {C_TITLE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ \){NC}"
echo -e "\( {C_TITLE}┃       nebulaX berhasil terpasang!   ┃ \){NC}"
echo -e "\( {C_TITLE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ \){NC}"
echo -e "${C_LABEL}→ Ketik \( {C_HL}zsh \){C_LABEL} atau buka terminal baru${NC}"
echo -e "${C_LABEL}→ Ketik \( {C_HL}help \){C_LABEL} untuk melihat perintah bantu${NC}\n"