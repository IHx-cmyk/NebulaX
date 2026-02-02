#!/usr/bin/env bash

# =============================================================================
# nebulaX Ultimate Terminal
# =============================================================================

# Warna untuk output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Animasi loading
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Clear screen dengan style
clear_screen() {
    printf "\033[H\033[2J"
}

# Header nebulaX
show_header() {
    clear_screen
    echo -e "${MAGENTA}${BOLD}"
    cat << "EOF"
  ███╗   ██╗███████╗██████╗ ██╗   ██╗██╗      █████╗      ██╗  ██╗
  ████╗  ██║██╔════╝██╔══██╗██║   ██║██║     ██╔══██╗     ╚██╗██╔╝
  ██╔██╗ ██║█████╗  ██████╔╝██║   ██║██║     ███████║      ╚███╔╝ 
  ██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║      ██╔██╗ 
  ██║ ╚████║███████╗██████╔╝╚██████╔╝███████╗██║  ██║     ██╔╝ ██╗
  ╚═╝  ╚═══╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝     ╚═╝  ╚═╝
EOF
    echo -e "${NC}${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}           Terminal Suite with Auto Powerlevel10k${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Backup existing configs
backup_configs() {
    echo -e "${CYAN}→ Backup konfigurasi yang ada...${NC}"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    # Backup .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$TIMESTAMP"
        echo -e "${GREEN}✓ .zshrc dibackup: .zshrc.backup.$TIMESTAMP${NC}"
    fi
    
    # Backup .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$TIMESTAMP"
        echo -e "${GREEN}✓ .bashrc dibackup${NC}"
    fi
    
    # Backup oh-my-zsh jika ada
    if [ -d "$HOME/.oh-my-zsh" ]; then
        mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.backup.$TIMESTAMP" 2>/dev/null
        echo -e "${GREEN}✓ oh-my-zsh dibackup${NC}"
    fi
}

# Install dependencies
install_dependencies() {
    echo -e "${CYAN}→ Install dependensi...${NC}"
    
    # Cek package manager
    if command -v pkg >/dev/null 2>&1; then
        echo -e "${GRAY}Platform: Termux${NC}"
        PKG_CMD="pkg install -y"
        $PKG_CMD update -y >/dev/null 2>&1
    elif command -v apt >/dev/null 2>&1; then
        echo -e "${GRAY}Platform: Debian/Ubuntu${NC}"
        PKG_CMD="sudo apt install -y"
        sudo apt update -y >/dev/null 2>&1
    elif command -v yum >/dev/null 2>&1; then
        echo -e "${GRAY}Platform: RHEL/CentOS${NC}"
        PKG_CMD="sudo yum install -y"
    elif command -v pacman >/dev/null 2>&1; then
        echo -e "${GRAY}Platform: Arch Linux${NC}"
        PKG_CMD="sudo pacman -S --noconfirm"
    else
        echo -e "${YELLOW}⚠ Package manager tidak dikenali${NC}"
        return 1
    fi
    
    # Install package dasar
    PACKAGES="zsh git curl wget nano"
    
    echo -e "${GRAY}Installing: $PACKAGES${NC}"
    for package in $PACKAGES; do
        $PKG_CMD "$package" >/dev/null 2>&1 &
        show_spinner $!
    done
    
    echo -e "${GREEN}✓ Dependensi terinstall${NC}"
}

# Install Powerlevel10k dan plugins
install_plugins() {
    echo -e "${CYAN}→ Install Powerlevel10k dan plugins...${NC}"
    
    NEBULA_DIR="$HOME/.nebulaX"
    ZSH_CUSTOM="$NEBULA_DIR/oh-my-zsh/custom"
    
    # Buat direktori
    mkdir -p "$NEBULA_DIR"
    mkdir -p "$ZSH_CUSTOM/themes"
    mkdir -p "$ZSH_CUSTOM/plugins"
    mkdir -p "$NEBULA_DIR/bin"
    
    # Clone Powerlevel10k
    echo -e "${GRAY}Downloading Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" >/dev/null 2>&1 &
    show_spinner $!
    
    # Clone plugins penting
    PLUGINS=(
        "https://github.com/zsh-users/zsh-autosuggestions"
        "https://github.com/zsh-users/zsh-syntax-highlighting"
        "https://github.com/zsh-users/zsh-completions"
    )
    
    for plugin_url in "${PLUGINS[@]}"; do
        plugin_name=$(basename "$plugin_url")
        echo -e "${GRAY}Downloading $plugin_name...${NC}"
        git clone --depth=1 "$plugin_url" "$ZSH_CUSTOM/plugins/$plugin_name" >/dev/null 2>&1 &
        show_spinner $!
    done
    
    # Clone tambahan plugins berguna
    echo -e "${GRAY}Downloading additional plugins...${NC}"
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" >/dev/null 2>&1 &
    show_spinner $!
    
    git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete "$ZSH_CUSTOM/plugins/zsh-autocomplete" >/dev/null 2>&1 &
    show_spinner $!
    
    echo -e "${GREEN}✓ Powerlevel10k dan plugins terinstall${NC}"
}

# Buat config
create_p10k_config() {
    echo -e "${CYAN}→ Buat konfigurasi Powerlevel10k otomatis...${NC}"
    
    cat > "$HOME/.p10k.zsh" << 'P10K_CONFIG'
# Generated by nebulaX - Auto Powerlevel10k configuration

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return 1

  # Prompt colors.
  local grey='242'
  local red='1'
  local yellow='3'
  local blue='4'
  local magenta='5'
  local cyan='6'
  local white='7'

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    context
    dir
    vcs
    # =========================[ Line #2 ]=========================
    newline
    prompt_char
  )

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    status
    command_execution_time
    background_jobs
    time
    # =========================[ Line #2 ]=========================
    newline
  )

  # Basic style options.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add an empty line before each prompt.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Context.
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='7'
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND='0'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'

  # Directory.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='7'
  typeset -g POWERLEVEL9K_DIR_BACKGROUND='4'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='7'
  typeset -g POWERLEVEL9K_DIR_SHORTEN_STRATEGY='truncate_to_unique'
  typeset -g POWERLEVEL9K_DIR_SHORTEN_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true

  # Git status.
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='2'
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND='0'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='2'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='0'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='3'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='0'

  # Status.
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='1'
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND='0'

  # Command execution time.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='7'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='0'

  # Background jobs.
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='6'
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='0'

  # Time.
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='7'
  typeset -g POWERLEVEL9K_TIME_BACKGROUND='0'
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

  # Prompt character.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='6'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='1'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # Transient prompt works similarly to the builtin transient_rprompt option.
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  # Instant prompt mode.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

  # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # If p10k is already loaded, reload configuration.
  (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
P10K_CONFIG
    
    echo -e "${GREEN}✓ Konfigurasi Powerlevel10k dibuat${NC}"
}

# Buat banner nebulaX
create_banner() {
    echo -e "${CYAN}→ Buat banner nebulaX...${NC}"
    
    cat > "$HOME/.nebulaX/banner.sh" << 'BANNER_EOF'
#!/bin/bash
# nebulaX Banner - Simple and clean

# Colors
R='\033[0m'
B='\033[1m'
M='\033[35m'
C='\033[36m'
W='\033[37m'
G='\033[32m'

# Get terminal width
COLS=$(tput cols 2>/dev/null || echo 80)
if [ $COLS -lt 60 ]; then
    COLS=60
fi

# Simple nebulaX header
printf "${M}${B}"
printf '%*s\n' $(( (${#1}+COLS)/2 )) "nebulaX Terminal"
printf "${C}"
printf '═%.0s' $(seq 1 $COLS)
printf "${R}\n\n"

# Quick info
printf "${G}User:${W} %s\n" "$(whoami)"
printf "${G}Time:${W} %s\n" "$(date '+%H:%M:%S')"
printf "${G}Date:${W} %s\n" "$(date '+%Y-%m-%d')"
printf "\n"

# Quick tip
printf "${C}Tip:${W} Type 'help' for commands\n"
printf "${C}Theme:${W} Powerlevel10k (auto configured)\n"
printf "\n"
BANNER_EOF
    
    chmod +x "$HOME/.nebulaX/banner.sh"
    echo -e "${GREEN}✓ Banner dibuat${NC}"
}

# Buat utility commands
create_utilities() {
    echo -e "${CYAN}→ Buat utility commands...${NC}"
    
    NEBULA_BIN="$HOME/.nebulaX/bin"
    
    # Command: help
    cat > "$NEBULA_BIN/help" << 'HELP_EOF'
#!/bin/bash
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║               nebulaX - HELP MENU               ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "System:"
echo "  help       - Show this help"
echo "  banner     - Show nebulaX banner"
echo "  update     - Update system packages"
echo "  myip       - Show public IP address"
echo ""
echo "File Operations:"
echo "  list       - List files with details"
echo "  findf      - Find files by name"
echo "  size       - Check directory size"
echo ""
echo "Terminal:"
echo "  cls        - Clear screen"
echo "  fonts      - List available fonts"
echo "  theme      - Powerlevel10k theme (auto)"
echo ""
echo "Git Shortcuts:"
echo "  gs         - git status"
echo "  ga <file>  - git add"
echo "  gc <msg>   - git commit"
echo "  gp         - git push"
echo ""
echo "Powerlevel10k is already configured automatically!"
echo "No configuration needed - just enjoy your terminal!"
HELP_EOF
    
    # Command: myip
    cat > "$NEBULA_BIN/myip" << 'MYIP_EOF'
#!/bin/bash
echo "Public IP Address:"
curl -s https://api.ipify.org || curl -s https://icanhazip.com || echo "Unable to get IP"
echo ""
MYIP_EOF
    
    # Command: cls (clear dengan banner)
    cat > "$NEBULA_BIN/cls" << 'CLS_EOF'
#!/bin/bash
clear
if [ -f "$HOME/.nebulaX/banner.sh" ]; then
    bash "$HOME/.nebulaX/banner.sh"
fi
CLS_EOF
    
    # Command: update system
    cat > "$NEBULA_BIN/update" << 'UPDATE_EOF'
#!/bin/bash
echo "Updating system..."
if command -v pkg >/dev/null 2>&1; then
    pkg update -y && pkg upgrade -y
elif command -v apt >/dev/null 2>&1; then
    sudo apt update -y && sudo apt upgrade -y
elif command -v yum >/dev/null 2>&1; then
    sudo yum update -y
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu --noconfirm
else
    echo "Package manager not found"
fi
echo "Update complete!"
UPDATE_EOF
    
    # Command: banner
    cat > "$NEBULA_BIN/banner" << 'BANNER_CMD_EOF'
#!/bin/bash
bash "$HOME/.nebulaX/banner.sh"
BANNER_CMD_EOF
    
    # Command: theme info
    cat > "$NEBULA_BIN/theme" << 'THEME_EOF'
#!/bin/bash
echo ""
echo "Powerlevel10k Theme Information:"
echo "================================"
echo "Theme: nebulaX Auto-Configured"
echo "Style: Clean and minimal"
echo "Colors: Automatic based on terminal"
echo "Configuration: ~/.p10k.zsh"
echo ""
echo "To reconfigure (if needed):"
echo "  p10k configure"
echo ""
THEME_EOF
    
    # Beri permission executable
    chmod +x "$NEBULA_BIN"/*
    
    echo -e "${GREEN}✓ Utility commands dibuat${NC}"
}

# Buat .zshrc utama
create_zshrc() {
    echo -e "${CYAN}→ Buat konfigurasi ZSH utama...${NC}"
    
    NEBULA_DIR="$HOME/.nebulaX"
    ZSH_CUSTOM="$NEBULA_DIR/oh-my-zsh/custom"
    
    cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# =============================================================================
# nebulaX ZSH Configuration
# Powerlevel10k Auto-Configured - No questions asked!
# =============================================================================

# Enable Powerlevel10k instant prompt (if supported)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set nebulaX paths
export NEBULA_HOME="$HOME/.nebulaX"
export ZSH_CUSTOM="$NEBULA_HOME/oh-my-zsh/custom"
export PATH="$PATH:$NEBULA_HOME/bin"

# Load nebulaX banner on first start
if [[ -z "$NEBULA_LOADED" ]]; then
    clear
    if [[ -f "$NEBULA_HOME/banner.sh" ]]; then
        source "$NEBULA_HOME/banner.sh"
    fi
    export NEBULA_LOADED=1
fi

# Oh My Zsh configuration
export ZSH="$NEBULA_HOME/oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (fast and useful)
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fast-syntax-highlighting
    zsh-autocomplete
)

# Source Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Source Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Plugin configurations
# ZSH Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ZSH Syntax Highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_STYLES[cursor]='bold'

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt share_history

# Aliases for common commands
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear && [[ -f "$NEBULA_HOME/banner.sh" ]] && source "$NEBULA_HOME/banner.sh"'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gcl='git clone'
alias gcm='git commit -m'
alias gco='git checkout'
alias gbr='git branch'
alias gl='git log --oneline --graph'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# nebulaX commands
alias help='help'
alias myip='myip'
alias banner='banner'
alias update='update'
alias theme='theme'
alias list='ls -la'
alias findf='find . -type f -name'
alias size='du -sh'

# Function to reload configuration
reload() {
    source ~/.zshrc
    echo "Configuration reloaded!"
}

# Function to update nebulaX
update-nebula() {
    echo "Updating nebulaX..."
    curl -s https://raw.githubusercontent.com/yourusername/nebulax/main/install.sh | bash
}

# Welcome message
echo ""
echo -e "\033[35m✦ nebulaX Terminal is ready! ✦\033[0m"
echo -e "\033[36mPowerlevel10k is auto-configured. No setup needed!\033[0m"
echo -e "\033[90mType 'help' for available commands\033[0m"
echo ""
ZSHRC_EOF
    
    echo -e "${GREEN}✓ Konfigurasi ZSH dibuat${NC}"
}

# Setup Oh My Zsh framework
setup_ohmyzsh() {
    echo -e "${CYAN}→ Setup Oh My Zsh framework...${NC}"
    
    NEBULA_DIR="$HOME/.nebulaX"
    
    # Clone Oh My Zsh minimal
    echo -e "${GRAY}Downloading Oh My Zsh...${NC}"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$NEBULA_DIR/oh-my-zsh" >/dev/null 2>&1 &
    show_spinner $!
    
    # Buat file oh-my-zsh.sh sederhana
    cat > "$NEBULA_DIR/oh-my-zsh/oh-my-zsh.sh" << 'OMZ_EOF'
# Check for updates on initial load...
if [[ "$DISABLE_AUTO_UPDATE" != true ]]; then
  env ZSH="$ZSH" DISABLE_UPDATE_PROMPT="$DISABLE_UPDATE_PROMPT" zsh -f "$ZSH/tools/check_for_upgrade.sh" 2>/dev/null || true
fi

# Initialize completions
autoload -Uz compinit
compinit -i

# Load all of the config files in ~/oh-my-zsh that end in .zsh
for config_file ("$ZSH"/lib/*.zsh); do
  source "$config_file"
done

# Load all enabled plugins
for plugin ($plugins); do
  if [ -f "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ]; then
    source "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh"
  elif [ -f "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]; then
    source "$ZSH/plugins/$plugin/$plugin.plugin.zsh"
  fi
done

# Load the theme
if [[ "$ZSH_THEME" == "random" ]]; then
  themes=("$ZSH"/themes/*.zsh-theme)
  N=${#themes[@]}
  ((N=(RANDOM%N)+1))
  RANDOM_THEME=${themes[$N]}
  source "$RANDOM_THEME"
elif [[ -n "$ZSH_THEME" ]]; then
  if [[ -f "$ZSH_CUSTOM/themes/$ZSH_THEME/$ZSH_THEME.zsh-theme" ]]; then
    source "$ZSH_CUSTOM/themes/$ZSH_THEME/$ZSH_THEME.zsh-theme"
  elif [[ -f "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme" ]]; then
    source "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme"
  elif [[ -f "$ZSH/themes/$ZSH_THEME.zsh-theme" ]]; then
    source "$ZSH/themes/$ZSH_THEME.zsh-theme"
  fi
fi
OMZ_EOF
    
    echo -e "${GREEN}✓ Oh My Zsh setup complete${NC}"
}

# Set ZSH as default shell
set_default_shell() {
    echo -e "${CYAN}→ Set ZSH sebagai default shell...${NC}"
    
    # Cek jika ZSH sudah default
    if [[ "$SHELL" != *"zsh"* ]]; then
        # Coba gunakan chsh
        if command -v chsh >/dev/null 2>&1; then
            chsh -s $(which zsh) >/dev/null 2>&1
            echo -e "${GREEN}✓ Shell diubah ke ZSH${NC}"
        else
            # Fallback untuk Termux
            if [[ -f /data/data/com.termux/files/usr/bin/zsh ]]; then
                echo -e "${YELLOW}⚠ Jalankan manual: chsh -s $(which zsh)${NC}"
            fi
        fi
    else
        echo -e "${GREEN}✓ ZSH sudah default shell${NC}"
    fi
}

# Final installation
finalize() {
    echo -e "${CYAN}→ Finalisasi instalasi...${NC}"
    
    # Add to PATH permanently
    if ! grep -q "NEBULA_HOME" "$HOME/.profile" 2>/dev/null; then
        echo 'export NEBULA_HOME="$HOME/.nebulaX"' >> "$HOME/.profile"
        echo 'export PATH="$PATH:$NEBULA_HOME/bin"' >> "$HOME/.profile"
    fi
    
    echo ""
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}nebulaX dengan Powerlevel10k berhasil diinstall!${NC}"
    echo ""
    echo -e "${CYAN}Untuk mulai menggunakan:${NC}"
    echo -e "  1. ${WHITE}Tutup dan buka terminal baru${NC}"
    echo -e "  2. ${WHITE}Atau ketik: zsh${NC}"
    echo ""
    echo -e "${GREEN}Powerlevel10k sudah dikonfigurasi otomatis!${NC}"
    echo -e "${YELLOW}Tidak ada pertanyaan konfigurasi - langsung siap pakai!${NC}"
    echo ""
    echo -e "${CYAN}Ketik ${WHITE}help${CYAN} untuk melihat perintah yang tersedia${NC}"
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Tampilkan preview
    if [ -f "$HOME/.nebulaX/banner.sh" ]; then
        echo -e "${CYAN}Preview banner nebulaX:${NC}"
        echo ""
        bash "$HOME/.nebulaX/banner.sh"
    fi
}

# Main installation process
main() {
    show_header
    
    # Start installation
    backup_configs
    install_dependencies
    install_plugins
    setup_ohmyzsh
    create_p10k_config
    create_banner
    create_utilities
    create_zshrc
    set_default_shell
    finalize
}

# Run installation
main "$@"