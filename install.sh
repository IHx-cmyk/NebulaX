#!/data/data/com.termux/files/usr/bin/bash

# --- WARNA INSTALLER (Standard) ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

clear
echo -e "${PURPLE}"
echo "========================================"
echo "   N E B U L A - X  |  ULTIMATE V2    "
echo "========================================"
echo -e "${NC}"

# 1. Update & Install Dependencies
echo -e "${CYAN}[*] Menyiapkan environment...${NC}"
pkg update -y && pkg upgrade -y
pkg install zsh git curl wget tar unzip unrar -y

# 2. Setup Folder
INSTALL_DIR="$HOME/.nebulaX"
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${PURPLE}[*] Versi lama terdeteksi, menimpa instalasi...${NC}"
fi
mkdir -p "$INSTALL_DIR/plugins"

# 3. Download Plugin (The Big 4)
echo -e "${CYAN}[*] Mendownload Plugin ZSH...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions "$INSTALL_DIR/plugins/zsh-autosuggestions" --depth 1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$INSTALL_DIR/plugins/zsh-syntax-highlighting" --depth 1
git clone https://github.com/zsh-users/zsh-completions "$INSTALL_DIR/plugins/zsh-completions" --depth 1
git clone https://github.com/zsh-users/zsh-history-substring-search "$INSTALL_DIR/plugins/zsh-history-substring-search" --depth 1

# 4. Membuat File Banner (ASCII ART)
echo -e "${CYAN}[*] Membuat Banner Aesthetics...${NC}"
cat > "$INSTALL_DIR/banner.sh" <<'EOF'
#!/bin/bash
# Warna Hex/256 untuk Gradasi Ungu
P1='\e[38;5;93m'  # Ungu Gelap
P2='\e[38;5;129m' # Ungu Sedang
P3='\e[38;5;141m' # Ungu Terang
P4='\e[38;5;147m' # Lavender
WT='\e[38;5;255m' # Putih
RS='\e[0m'        # Reset

# Clear screen dulu biar bersih
clear

echo -e "${P1}        ,MMM8&&&. ${RS}"
echo -e "${P1}   _MMMMMMM888888&. ${RS}"
echo -e "${P2}  MMMMMM88888888888& ${RS}"
echo -e "${P2}  MMMMMM888888888888 ${RS}"
echo -e "${P3}   \`MMMM88888888888' ${RS}"
echo -e "${P3}       \`YMM8888888' ${RS}"
echo -e "${P4}         \`\"\"\"\"\"\"' ${RS}"
echo ""
echo -e "${P1}███╗   ██╗${P2}███████╗${P3}██████╗ ${P4}██╗   ██╗${P1}██╗      █████╗ ${P2}██╗  ██╗${RS}"
echo -e "${P1}████╗  ██║${P2}██╔════╝${P3}██╔══██╗${P4}██║   ██║${P1}██║     ██╔══██╗${P2}╚██╗██╔╝${RS}"
echo -e "${P1}██╔██╗ ██║${P2}█████╗  ${P3}██████╔╝${P4}██║   ██║${P1}██║     ███████║${P2} ╚███╔╝ ${RS}"
echo -e "${P1}██║╚██╗██║${P2}██╔══╝  ${P3}██╔══██╗${P4}██║   ██║${P1}██║     ██╔══██║${P2} ██╔██╗ ${RS}"
echo -e "${P1}██║ ╚████║${P2}███████╗${P3}██████╔╝${P4}╚██████╔╝${P1}███████╗██║  ██║${P2}██╔╝ ██╗${RS}"
echo -e "${P1}╚═╝  ╚═══╝${P2}╚══════╝${P3}╚═════╝ ${P4} ╚═════╝ ${P1}╚══════╝╚═╝  ╚═╝${P2}╚═╝  ╚═╝${RS}"
echo -e "       ${WT}:: NebulaX Termux Edition ::${RS}\n"
EOF

# 5. Membuat Konfigurasi Tema (Prompt)
cat > "$INSTALL_DIR/nebulaX.zsh-theme" <<EOF
# Warna Prompt
P_DARK='%F{093}'
P_MID='%F{129}'
P_LIGHT='%F{213}'
P_CYAN='%F{051}'
P_WHITE='%F{255}'
RESET='%f'

setopt prompt_subst

function git_stat() {
  ref=\$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "\${P_LIGHT}(\${ref#refs/heads/})\${RESET}"
}

# Prompt 2 Baris yang Cantik
# Baris 1: ╭─[DIR] [GIT]
# Baris 2: ╰─👾 ->
PROMPT="\${P_DARK}╭─\${P_MID}[\${P_CYAN}%~\${P_MID}] \$(git_stat)
\${P_DARK}╰─\${P_LIGHT}👾 \${RESET}"

# Kanan: Jam
RPROMPT="\${P_DARK}%t\${RESET}"
EOF

# 6. Membuat .zshrc SUPER (Backup yang lama dulu)
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup_nebulaX"
fi

cat > "$HOME/.zshrc" <<EOF
# --- NEBULA-X CONFIGURATION ---

# 1. Tampilkan Banner setiap buka
source $INSTALL_DIR/banner.sh

# 2. History Setting (Biar gak ilang-ilang)
HISTFILE=\$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # Share history antar sesi
setopt HIST_IGNORE_DUPS       # Jangan simpan command duplikat
setopt HIST_IGNORE_SPACE      # Command dengan spasi di awal gak disimpan

# 3. Load Tema & Plugin
source $INSTALL_DIR/nebulaX.zsh-theme
fpath=($INSTALL_DIR/plugins/zsh-completions/src \$fpath)
source $INSTALL_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $INSTALL_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $INSTALL_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# 4. Fitur Completion Menu (Pilih file pake panah!)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "\${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive

# 5. Keybindings (Tombol Panah Atas/Bawah buat cari history)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 6. ALIAS GACOR (Helper)
alias c='clear'
alias q='exit'
alias ll='ls -l'
alias la='ls -la'
alias install='pkg install'
alias update='pkg update && pkg upgrade'
alias remove='pkg uninstall'
alias myip='curl ifconfig.me'
alias ports='netstat -tulpn'
alias speed='echo "Testing internet..." && curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python'

# Safety Nets (Biar gak sembarang hapus/tumpuk)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 7. FUNGSI SAKTI (Helper Functions)

# Extract apa saja (zip, tar, rar, bz2) tinggal ketik: x namafile
x() {
    if [ -f \$1 ] ; then
        case \$1 in
            *.tar.bz2)   tar xjf \$1     ;;
            *.tar.gz)    tar xzf \$1     ;;
            *.bz2)       bunzip2 \$1     ;;
            *.rar)       unrar e \$1     ;;
            *.gz)        gunzip \$1      ;;
            *.tar)       tar xf \$1      ;;
            *.tbz2)      tar xjf \$1     ;;
            *.tgz)       tar xzf \$1     ;;
            *.zip)       unzip \$1       ;;
            *.Z)         uncompress \$1  ;;
            *.7z)        7z x \$1        ;;
            *)           echo "'\$1' tidak bisa diekstrak via extract()" ;;
        esac
    else
        echo "'\$1' bukan file valid!"
    fi
}

# Buat folder langsung masuk
mkcd() {
    mkdir -p "\$1" && cd "\$1"
}

EOF

# 7. Ganti Shell
chsh -s zsh

echo -e "${GREEN}"
echo "========================================"
echo "    NEBULA-X TERINSTALL SEMPURNA!       "
echo "    Ketik 'zsh' untuk masuk ke dunia    "
echo "    Nebula yang ungu & cantik...        "
echo "========================================"
echo -e "${NC}"
