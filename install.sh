#!/data/data/com.termux/files/usr/bin/bash
# install-nebulaX-advanced.sh - NebulaX theme mirip Stellar tapi pure bash + purple nebula

set -e

echo "Install NebulaX Advanced (purple nebula vibe + boxed info)..."

pkg install figlet boxes neofetch bash-completion lolcat -y || true

# Backup
[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak-nebulaX-$(date +%Y%m%d)

# Buat .bashrc nebulaX
cat > ~/.bashrc << 'EOF'
# ╭───────────────────────────────────────────────────────────────╮
# │ nebulaX Theme - Purple Nebula Cosmic Vibe (mirip Stellar)     │
# ╰───────────────────────────────────────────────────────────────╯

# Warna purple nebula dominant
P1='\033[38;5;135m'   # purple soft
P2='\033[38;5;141m'   # purple brighter
P3='\033[38;5;147m'   # purple light
C1='\033[38;5;39m'    # cyan nebula
M1='\033[38;5;207m'   # magenta/pink accent
RESET='\033[0m'

clear

# ASCII Nebula art (manual multi-line + lolcat untuk gradient purple-cyan)
echo -e "${P1}"
cat << 'ART' | lolcat
     .          .     *       .      .   *      .      *    .
   .    *     .    .      .     *        .     .       .    
      .      .   *     .     .      .     *     .     .     
 *     .     .      .     *    .      .     .     *     .   
   .     *      .     .      .     *     .      .     .     
      .      .     *     .      .     .     *     .      .  
    *     .      .     .     *     .      .     .     *     
 .      .     *     .      .     .     *     .      .     *
ART
echo -e "${RESET}"

# Banner text nebulaX
echo -e "  \( {P2}✦  nebulaX  ✦ \){RESET}   \( {M1}digital cosmos explorer \){RESET}"
echo ""

# Boxed OS/Device Info (mirip Stellar table tapi pakai boxes)
neofetch --stdout | boxes -d parchment -p h1 -a c | lolcat
# Atau kalau mau lebih custom, uncomment ini:
# {
#   echo "Hostname : $(hostname)"
#   echo "Kernel   : $(uname -r)"
#   echo "Uptime   : $(uptime -p)"
#   echo "Shell    : $BASH"
#   echo "User     : \( (whoami)@ \)(hostname)"
#   echo "CPU      : $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
# } | boxes -d stone -p h2 -a c | lolcat

echo ""

# Enable bash completion & history enhancement
if [ -f /data/data/com.termux/files/usr/share/bash-completion/bash_completion ]; then
    . /data/data/com.termux/files/usr/share/bash-completion/bash_completion
fi

# History lebih cerdas: ignore duplicates, unlimited size, search dengan arrow up/down
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend
shopt -s cmdhist
bind '"\e[A": history-search-backward'   # ↑ search history
bind '"\e[B": history-search-forward'    # ↓ search history
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# Prompt custom nebula style (user@host path dengan purple)
PS1='\n\( {P1}┌─ \){P2}[\( {C1}\u \){P1}@${M1}\h \( {P3}\w \){P2}]\( {P1}─ \){RESET}\n\( {P1}└─ \){M1}➜${RESET} '

EOF

# Optional: warna terminal lebih nebula purple
mkdir -p ~/.termux
cat > ~/.termux/colors.properties << 'EOF'
foreground=#d5c4ff
background=#0c0025
cursor=#ff79c6
color0=#0c0025
color1=#ff6e67
color2=#61ffca
color3=#ffca85
color4=#7aa2f7
color5=#bb9af7
color6=#7dcfff
color7=#c0caf5
color8=#444b6a
color9=#ff5370
color10=#69ff94
color11=#ffd47e
color12=#89b4fa
color13=#c792ea
color14=#80d8ff
color15=#ffffff
EOF

termux-reload-settings 2>/dev/null || true

echo ""
echo "NebulaX Advanced installed! Purple nebula + boxed info + smart history"
echo "Tutup & buka Termux lagi untuk melihat full effect."
echo "Untuk hapus: jalankan ./remove-nebulaX.sh"
echo ""
