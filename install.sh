#!/usr/bin/env bash

# =============================================================================
# nebulaX - Ultimate Terminal (Termux-first, Linux/macOS secondary)
# =============================================================================

# Warna sederhana + fallback (banyak Termux pakai font buruk untuk 256 color)
if [[ -t 1 ]]; then
    C_RED='\033[31m'
    C_GREEN='\033[32m'
    C_YELLOW='\033[33m'
    C_BLUE='\033[34m'
    C_MAGENTA='\033[35m'
    C_CYAN='\033[36m'
    C_WHITE='\033[97m'
    C_GRAY='\033[90m'
    C_BOLD='\033[1m'
    NC='\033[0m'
else
    # No color if not terminal
    C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN='' C_WHITE='' C_GRAY='' C_BOLD='' NC=''
fi

clear
echo -e "\( {C_MAGENTA} \){C_BOLD}══════════════════════════════════════════════${NC}"
echo -e "          nebulaX  •  ULTIMATE TERMINAL${NC}"
echo -e "\( {C_MAGENTA}══════════════════════════════════════════════ \){NC}\n"

echo -e "\( {C_CYAN}→ Mengamankan shell lain... \){NC}"
[ -d "$HOME/.oh-my-zsh" ]       && mv "$HOME/.oh-my-zsh"       "$HOME/.oh-my-zsh.bak.nebulax" 2>/dev/null
[ -f "$HOME/.zshrc" ]           && mv "$HOME/.zshrc"           "$HOME/.zshrc.bak.pre-nebulax" 2>/dev/null

# Package manager
if [[ -f /data/data/com.termux/files/usr/bin/bash ]]; then
    PKG="pkg install -y"
    $PKG update -y >/dev/null 2>&1
else
    PKG="sudo apt install -y"
fi

echo -e "\( {C_CYAN}→ Install dependensi... \){NC}"
$PKG zsh git curl wget bc 2>/dev/null || true

INSTALL_DIR="$HOME/.nebulaX"
rm -rf "$INSTALL_DIR" 2>/dev/null
mkdir -p "$INSTALL_DIR"/{plugins,bin}

echo -e "\( {C_CYAN}→ Download plugins... \){NC}"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions     "$INSTALL_DIR/plugins/zsh-autosuggestions"     2>/dev/null
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$INSTALL_DIR/plugins/zsh-syntax-highlighting" 2>/dev/null
git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search "$INSTALL_DIR/plugins/zsh-history-substring-search" 2>/dev/null

# ── Banner sederhana tapi reliable untuk Termux ─────────────────────────────
cat > "$INSTALL_DIR/banner.sh" <<'EOF'
#!/usr/bin/env bash

# Warna fallback-safe
R='\033[0m'  B='\033[1m'  M='\033[35m'  C='\033[36m'  W='\033[97m'

clear

COLS=\( {COLUMNS:- \)(stty size 2>/dev/null | cut -d' ' -f2 || echo 80)}
(( COLS < 50 )) && COLS=50

line() { printf '─%.0s' $(seq 1 $COLS); }

echo -e "\( {M} \){B}"
line
echo "               nebulaX  •  TERMINAL SUITE"
line
echo -e "${R}"

echo ""
echo -e "  \( {C}User    : \){W} $(whoami)"
echo -e "  \( {C}Date    : \){W} $(date '+%Y-%m-%d %H:%M')"
echo -e "  \( {C}Shell   : \){W} zsh"
echo ""
echo -e "  \( {M} \){B}»»»  nebulaX aktif  «««${R}"
echo ""
echo -e "  ${C}ketik ${W}help ${C}untuk perintah bantu"
echo ""
EOF

chmod +x "$INSTALL_DIR/banner.sh"

# ── Helpers ─────────────────────────────────────────────────────────────────
cat > "$INSTALL_DIR/bin/help" <<'EOF'
#!/usr/bin/env bash
echo ""
echo "nebulaX commands:"
echo "  help       → tampilkan ini"
echo "  scan       → cek port & file mencurigakan"
echo "  myip       → lihat IP publik"
echo "  cl / clear → bersihkan layar"
echo ""
EOF

cat > "$INSTALL_DIR/bin/myip" <<'EOF'
curl -s ifconfig.me || echo "gagal ambil IP"
EOF

chmod +x "$INSTALL_DIR/bin/"*

# ── Prompt sederhana (hindari kode rumit) ───────────────────────────────────
cat > "$INSTALL_DIR/nebulaX.zsh-theme" <<'EOF'
PROMPT='%F{magenta}┌─%f %F{cyan}[%~]%f 
└─%F{white}→ %f'
RPROMPT='%F{blue}%T%f'
EOF

# ── .zshrc ──────────────────────────────────────────────────────────────────
cat > "$HOME/.zshrc" <<EOF
# nebulaX config - jangan hapus baris ini kalau mau uninstall nanti

# Load banner hanya sekali (hindari spam)
if [[ -z "\$NEBULAX_LOADED" ]]; then
    clear
    bash $INSTALL_DIR/banner.sh
    export NEBULAX_LOADED=1
fi

# Plugins
source $INSTALL_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source $INSTALL_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source $INSTALL_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Theme
source $INSTALL_DIR/nebulaX.zsh-theme

# Path helpers
export PATH="\$PATH:$INSTALL_DIR/bin"

# Aliases
alias cl='clear'
alias h='help'
alias myip='myip'
alias up='pkg update -y && pkg upgrade -y'
EOF

echo -e "\n\( {C_GREEN} \){C_BOLD}nebulaX berhasil terpasang!${R}"
echo -e "Ketik \( {C_WHITE}zsh \){R} atau tutup & buka Termux lagi"
echo -e "Lalu ketik \( {C_WHITE}help \){R} untuk lihat perintah\n"

chsh -s zsh 2>/dev/null || echo "Ganti shell manual: chsh -s zsh"