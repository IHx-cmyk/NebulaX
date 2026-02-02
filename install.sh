#!/usr/bin/env bash

# =============================================================================
# nebulaX - Ultimate Terminal Suite
# =============================================================================

# Warna untuk output
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[97m'
GRAY='\033[90m'
BOLD='\033[1m'
NC='\033[0m'

# Fungsi untuk clear screen dengan animasi
clear_screen() {
    printf "\033[H\033[2J"
}

# Banner nebulaX dengan ASCII art
show_banner() {
    clear_screen
    
    # ASCII Art nebulaX
    cat << "EOF"
${MAGENTA}${BOLD}
    _   __      ______  __    _    ______
   / | / /___  / __/ / / /   | |  / / / /
  /  |/ / __ \/ /_/ / / /    | | / / / / 
 / /|  / /_/ / __/ /_/ /     | |/ / /_/  
/_/ |_/\____/_/  \____/      |___/\____/  
${NC}
${CYAN}╔══════════════════════════════════════════════════════════╗
║                Terminal Suite v2.0                ║
╚══════════════════════════════════════════════════════════╝${NC}
EOF
    
    echo -e "${GREEN}User    :${WHITE} $(whoami)"
    echo -e "${GREEN}Date    :${WHITE} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${GREEN}Shell   :${WHITE} $SHELL"
    echo -e "${GREEN}Host    :${WHITE} $(uname -n)"
    echo -e "${GREEN}OS      :${WHITE} $(uname -o) $(uname -m)"
    echo ""
    echo -e "${MAGENTA}${BOLD}>>> nebulaX Terminal Suite is ACTIVE <<<${NC}"
    echo ""
    echo -e "${CYAN}Type ${WHITE}help${CYAN} for available commands"
    echo -e "${CYAN}Type ${WHITE}menu${CYAN} for interactive menu"
    echo ""
}

# Backup existing configs
backup_configs() {
    echo -e "${CYAN}→ Backing up existing configurations...${NC}"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    [ -d "$HOME/.oh-my-zsh" ] && mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.backup.$TIMESTAMP" 2>/dev/null
    [ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$TIMESTAMP" 2>/dev/null
    [ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.backup.$TIMESTAMP" 2>/dev/null
    
    echo -e "${GREEN}✓ Backups created with timestamp: $TIMESTAMP${NC}"
}

# Install dependencies
install_dependencies() {
    echo -e "${CYAN}→ Installing dependencies...${NC}"
    
    # Detect package manager
    if command -v pkg >/dev/null 2>&1; then
        PKG_MGR="pkg"
        PKG_CMD="pkg install -y"
    elif command -v apt >/dev/null 2>&1; then
        PKG_MGR="apt"
        PKG_CMD="sudo apt update && sudo apt install -y"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MGR="yum"
        PKG_CMD="sudo yum install -y"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MGR="dnf"
        PKG_CMD="sudo dnf install -y"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MGR="pacman"
        PKG_CMD="sudo pacman -S --noconfirm"
    else
        echo -e "${YELLOW}⚠ Unknown package manager. Some features may not work.${NC}"
        return 1
    fi
    
    echo -e "${GRAY}Using package manager: $PKG_MGR${NC}"
    
    # Install essential packages
    PACKAGES="zsh git curl wget nano vim python3 python3-pip"
    
    if [[ $PKG_MGR == "pkg" ]]; then
        pkg update -y >/dev/null 2>&1
        for pkg in $PACKAGES; do
            if ! pkg list-installed | grep -q "$pkg"; then
                pkg install -y "$pkg" 2>/dev/null || echo -e "${YELLOW}⚠ Failed to install $pkg${NC}"
            else
                echo -e "${GRAY}✓ $pkg already installed${NC}"
            fi
        done
    else
        eval "$PKG_CMD $PACKAGES" 2>/dev/null || echo -e "${YELLOW}⚠ Some packages may have failed to install${NC}"
    fi
    
    echo -e "${GREEN}✓ Dependencies installed${NC}"
}

# Install plugins
install_plugins() {
    echo -e "${CYAN}→ Installing ZSH plugins...${NC}"
    
    NEBULA_DIR="$HOME/.nebulaX"
    PLUGINS_DIR="$NEBULA_DIR/plugins"
    
    # Create directories
    mkdir -p "$PLUGINS_DIR"
    mkdir -p "$NEBULA_DIR/bin"
    mkdir -p "$NEBULA_DIR/themes"
    mkdir -p "$NEBULA_DIR/scripts"
    
    # Clone plugins with progress indicator
    PLUGINS=(
        "https://github.com/zsh-users/zsh-autosuggestions"
        "https://github.com/zsh-users/zsh-syntax-highlighting"
        "https://github.com/zsh-users/zsh-history-substring-search"
        "https://github.com/zsh-users/zsh-completions"
        "https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git"
        "https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo"
    )
    
    for plugin in "${PLUGINS[@]}"; do
        plugin_name=$(basename "$plugin")
        echo -e "${GRAY}Installing: $plugin_name${NC}"
        
        if [[ "$plugin" == *"ohmyzsh"* ]]; then
            # For oh-my-zsh plugins, we need to handle them differently
            if [ ! -d "$PLUGINS_DIR/ohmyzsh" ]; then
                git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$PLUGINS_DIR/ohmyzsh" 2>/dev/null
            fi
        else
            git clone --depth=1 "$plugin.git" "$PLUGINS_DIR/$plugin_name" 2>/dev/null || \
            echo -e "${YELLOW}⚠ Failed to clone $plugin_name${NC}"
        fi
    done
    
    # Clone powerlevel10k theme
    echo -e "${GRAY}Installing: powerlevel10k theme${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$PLUGINS_DIR/powerlevel10k" 2>/dev/null || \
    echo -e "${YELLOW}⚠ Failed to clone powerlevel10k${NC}"
    
    echo -e "${GREEN}✓ Plugins installed${NC}"
}

# Create nebulaX configuration
create_config() {
    echo -e "${CYAN}→ Creating nebulaX configuration...${NC}"
    
    NEBULA_DIR="$HOME/.nebulaX"
    
    # Create banner script
    cat > "$NEBULA_DIR/banner.sh" << 'BANNER_EOF'
#!/bin/bash
# nebulaX Banner Script

# Colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[97m'
BOLD='\033[1m'
NC='\033[0m'

# Clear screen
clear

# Get terminal width
COLS=$(tput cols 2>/dev/null || echo 80)
(( COLS < 60 )) && COLS=60

# Print ASCII art
printf "${MAGENTA}${BOLD}"
cat << "EOF"
    _   __      ______  __    _    ______
   / | / /___  / __/ / / /   | |  / / / /
  /  |/ / __ \/ /_/ / / /    | | / / / / 
 / /|  / /_/ / __/ /_/ /     | |/ / /_/  
/_/ |_/\____/_/  \____/      |___/\____/  
EOF
printf "${NC}"

# Print header line
printf "${CYAN}"
printf '═%.0s' $(seq 1 $COLS)
printf "\n${WHITE}            nebulaX Terminal Suite v2.0\n"
printf "${CYAN}"
printf '═%.0s' $(seq 1 $COLS)
printf "${NC}\n\n"

# System info
printf "${GREEN}User    :${WHITE} %s\n" "$(whoami)"
printf "${GREEN}Date    :${WHITE} %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "${GREEN}Shell   :${WHITE} %s\n" "$SHELL"
printf "${GREEN}Host    :${WHITE} %s\n" "$(uname -n)"
printf "${GREEN}OS      :${WHITE} %s %s\n" "$(uname -o)" "$(uname -m)"
printf "${GREEN}Uptime  :${WHITE} %s\n" "$(uptime -p 2>/dev/null | sed 's/up //' || echo 'N/A')"

printf "\n${MAGENTA}${BOLD}╔══════════════════════════════════════════════════╗\n"
printf "║           ✦ nebulaX is ACTIVE ✦            ║\n"
printf "╚══════════════════════════════════════════════════╝${NC}\n\n"

printf "${CYAN}Commands:${WHITE} help ${CYAN}|${WHITE} menu ${CYAN}|${WHITE} tools ${CYAN}|${WHITE} update ${CYAN}|${WHITE} about\n"
printf "${CYAN}Quick:${WHITE} cls ${CYAN}to clear,${WHITE} exit ${CYAN}to quit\n\n"
BANNER_EOF
    
    chmod +x "$NEBULA_DIR/banner.sh"
    
    # Create help command
    cat > "$NEBULA_DIR/bin/help" << 'HELP_EOF'
#!/bin/bash
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║               nebulaX COMMAND MENU              ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "System Commands:"
echo "  help       - Show this help"
echo "  menu       - Interactive menu"
echo "  update     - Update nebulaX"
echo "  about      - About nebulaX"
echo ""
echo "Utility Commands:"
echo "  myip       - Show public IP"
echo "  weather    - Check weather"
echo "  speedtest  - Internet speed test"
echo "  calc       - Calculator"
echo ""
echo "File Operations:"
echo "  list       - List files with details"
echo "  findf      - Find files"
echo "  size       - Check directory size"
echo ""
echo "Network Tools:"
echo "  portscan   - Simple port scanner"
echo "  pingtest   - Ping multiple hosts"
echo "  netinfo    - Network information"
echo ""
echo "Terminal:"
echo "  cls        - Clear screen (with banner)"
echo "  theme      - Change color theme"
echo "  fonts      - List available fonts"
echo ""
HELP_EOF
    
    # Create other utility commands
    cat > "$NEBULA_DIR/bin/menu" << 'MENU_EOF'
#!/bin/bash
# Interactive menu for nebulaX

while true; do
    clear
    echo "╔══════════════════════════════════════════════════╗"
    echo "║             NEBULAX INTERACTIVE MENU            ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo ""
    echo "1. System Information"
    echo "2. Network Tools"
    echo "3. File Operations"
    echo "4. Terminal Settings"
    echo "5. Install Packages"
    echo "6. Update nebulaX"
    echo "7. About"
    echo "0. Exit"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1)
            clear
            echo "System Information:"
            echo "=================="
            neofetch --ascii_distro termux 2>/dev/null || \
            echo "OS: $(uname -o)"
            echo "Kernel: $(uname -r)"
            echo "Arch: $(uname -m)"
            echo "Shell: $SHELL"
            echo "User: $(whoami)"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        2)
            clear
            echo "Network Tools:"
            echo "============="
            echo "1. Check Public IP"
            echo "2. Speed Test"
            echo "3. Ping Google"
            echo "4. Back"
            echo ""
            read -p "Select: " net_choice
            case $net_choice in
                1) myip;;
                2) speedtest;;
                3) ping -c 4 google.com;;
            esac
            read -p "Press Enter to continue..."
            ;;
        3)
            clear
            echo "File Operations:"
            echo "================"
            echo "1. List Files (detailed)"
            echo "2. Find File"
            echo "3. Disk Usage"
            echo "4. Back"
            echo ""
            read -p "Select: " file_choice
            case $file_choice in
                1) ls -la;;
                2) read -p "Enter filename: " fname && find . -name "*$fname*" 2>/dev/null | head -20;;
                3) du -sh ./* 2>/dev/null | sort -h;;
            esac
            read -p "Press Enter to continue..."
            ;;
        4)
            clear
            echo "Terminal Settings:"
            echo "================="
            echo "1. Change Color Theme"
            echo "2. Change Font"
            echo "3. Reset Settings"
            echo "4. Back"
            echo ""
            read -p "Select: " term_choice
            case $term_choice in
                1) echo "Theme changer coming soon...";;
                2) echo "Font changer coming soon...";;
                3) echo "Reset feature coming soon...";;
            esac
            read -p "Press Enter to continue..."
            ;;
        5)
            clear
            echo "Package Installation:"
            echo "===================="
            echo "1. Install Common Tools"
            echo "2. Install Development"
            echo "3. Install Multimedia"
            echo "4. Back"
            echo ""
            read -p "Select: " pkg_choice
            case $pkg_choice in
                1) pkg install -y nano vim htop wget curl;;
                2) pkg install -y python nodejs git;;
                3) pkg install -y ffmpeg sox imagemagick;;
            esac
            read -p "Press Enter to continue..."
            ;;
        6)
            echo "Updating nebulaX..."
            curl -s https://raw.githubusercontent.com/yourusername/nebulax/main/install.sh | bash
            ;;
        7)
            clear
            echo "About nebulaX:"
            echo "=============="
            echo "Version: 2.0"
            echo "Author: © Shiny -Dev"
            echo "Description: Ultimate Terminal Suite"
            echo ""
            echo "GitHub: https://github.com/IHx-cmyk/NebulaX"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        0)
            break
            ;;
        *)
            echo "Invalid option!"
            sleep 1
            ;;
    esac
done
MENU_EOF
    
    # Create more utility commands
    cat > "$NEBULA_DIR/bin/myip" << 'MYIP_EOF'
#!/bin/bash
echo "Public IP Address:"
curl -s ifconfig.me || curl -s icanhazip.com || echo "Cannot determine IP"
echo ""
MYIP_EOF
    
    cat > "$NEBULA_DIR/bin/cls" << 'CLS_EOF'
#!/bin/bash
clear
exec $HOME/.nebulaX/banner.sh
CLS_EOF
    
    cat > "$NEBULA_DIR/bin/update" << 'UPDATE_EOF'
#!/bin/bash
echo "Updating nebulaX..."
cd "$HOME/.nebulaX" 2>/dev/null && git pull 2>/dev/null || \
echo "Update failed. Try reinstalling."
echo "Update complete!"
UPDATE_EOF
    
    # Make all binaries executable
    chmod +x "$NEBULA_DIR/bin/"*
    
    echo -e "${GREEN}✓ Configuration created${NC}"
}

# Create ZSH configuration
create_zshrc() {
    echo -e "${CYAN}→ Creating ZSH configuration...${NC}"
    
    NEBULA_DIR="$HOME/.nebulaX"
    
    cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# =============================================================================
# nebulaX ZSH Configuration
# This file is auto-generated. Do not edit manually.
# =============================================================================

# Path to nebulaX
export NEBULA_HOME="$HOME/.nebulaX"
export PATH="$PATH:$NEBULA_HOME/bin"

# Load banner on first start
if [ -z "$NEBULA_LOADED" ]; then
    clear
    source "$NEBULA_HOME/banner.sh"
    export NEBULA_LOADED=1
fi

# ZSH Options
setopt autocd              # Change directory without cd
setopt nomatch             # Error on unmatched patterns
setopt menucomplete        # Show completion menu
setopt interactivecomments # Allow comments in interactive shell
setopt histignorealldups   # Ignore duplicate commands in history
setopt sharehistory        # Share history between sessions

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# Load plugins
plugins=(
    "$NEBULA_HOME/plugins/zsh-autosuggestions"
    "$NEBULA_HOME/plugins/zsh-syntax-highlighting"
    "$NEBULA_HOME/plugins/zsh-history-substring-search"
    "$NEBULA_HOME/plugins/zsh-completions"
    "$NEBULA_HOME/plugins/powerlevel10k"
)

for plugin in "${plugins[@]}"; do
    if [ -d "$plugin" ]; then
        # Load the main plugin file
        if [ -f "$plugin/zsh-autosuggestions.zsh" ]; then
            source "$plugin/zsh-autosuggestions.zsh"
        elif [ -f "$plugin/zsh-syntax-highlighting.zsh" ]; then
            source "$plugin/zsh-syntax-highlighting.zsh"
        elif [ -f "$plugin/zsh-history-substring-search.zsh" ]; then
            source "$plugin/zsh-history-substring-search.zsh"
        elif [ -f "$plugin/powerlevel10k.zsh-theme" ]; then
            source "$plugin/powerlevel10k.zsh-theme"
        fi
    fi
done

# Load oh-my-zsh plugins if available
if [ -d "$NEBULA_HOME/plugins/ohmyzsh" ]; then
    source "$NEBULA_HOME/plugins/ohmyzsh/plugins/git/git.plugin.zsh" 2>/dev/null
    source "$NEBULA_HOME/plugins/ohmyzsh/plugins/sudo/sudo.plugin.zsh" 2>/dev/null
fi

# Key bindings for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Custom nebulaX prompt
PROMPT='%F{magenta}╭─%f %F{cyan}[%n@%m]%f %F{yellow}%~%f
%F{magenta}╰─%f%F{green}➤%f '
RPROMPT='%F{blue}[%T]%f'

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear && source $NEBULA_HOME/banner.sh'
alias update-nebula='$NEBULA_HOME/bin/update'
alias nebu-help='$NEBULA_HOME/bin/help'
alias nebu-menu='$NEBULA_HOME/bin/menu'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gpush='git push'
alias gpull='git pull'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Function to reload nebulaX
reload-nebula() {
    source ~/.zshrc
    echo "nebulaX reloaded!"
}

# Function to show system info
sysinfo() {
    echo "=== System Information ==="
    echo "User: $(whoami)"
    echo "Host: $(hostname)"
    echo "OS: $(uname -o)"
    echo "Kernel: $(uname -r)"
    echo "Arch: $(uname -m)"
    echo "Shell: $SHELL"
    echo "Terminal: $TERM"
    echo "=========================="
}

# Auto-completion
autoload -Uz compinit
compinit -i

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Welcome message
echo -e "\033[35mWelcome to \033[1mnebulaX Terminal Suite!\033[0m"
echo -e "Type \033[36mhelp\033[0m for commands or \033[36mmenu\033[0m for interactive menu\n"
ZSHRC_EOF
    
    echo -e "${GREEN}✓ ZSH configuration created${NC}"
}

# Set ZSH as default shell
set_default_shell() {
    echo -e "${CYAN}→ Setting ZSH as default shell...${NC}"
    
    if command -v chsh >/dev/null 2>&1; then
        if [[ "$SHELL" != *"zsh"* ]]; then
            chsh -s $(which zsh) 2>/dev/null && \
            echo -e "${GREEN}✓ Default shell changed to ZSH${NC}" || \
            echo -e "${YELLOW}⚠ Could not change default shell${NC}"
        else
            echo -e "${GREEN}✓ ZSH is already default shell${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ chsh not available. Run 'chsh -s \$(which zsh)' manually${NC}"
    fi
}

# Final installation steps
finalize_installation() {
    echo -e "${CYAN}→ Finalizing installation...${NC}"
    
    # Add nebulaX to PATH permanently
    if ! grep -q "NEBULA_HOME" "$HOME/.profile" 2>/dev/null; then
        echo 'export NEBULA_HOME="$HOME/.nebulaX"' >> "$HOME/.profile"
        echo 'export PATH="$PATH:$NEBULA_HOME/bin"' >> "$HOME/.profile"
    fi
    
    if ! grep -q "NEBULA_HOME" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export NEBULA_HOME="$HOME/.nebulaX"' >> "$HOME/.bashrc"
        echo 'export PATH="$PATH:$NEBULA_HOME/bin"' >> "$HOME/.bashrc"
    fi
    
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo ""
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}nebulaX has been successfully installed!${NC}"
    echo ""
    echo -e "${CYAN}To start using nebulaX:${NC}"
    echo -e "  1. Close and reopen your terminal"
    echo -e "  2. Or type: ${WHITE}zsh${NC}"
    echo -e "  3. Then type: ${WHITE}help${NC} for commands"
    echo ""
    echo -e "${YELLOW}Note:${NC} The banner will show every time you open a new terminal"
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Main installation process
main() {
    clear_screen
    echo -e "${MAGENTA}${BOLD}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║           NEBULAX INSTALLATION v2.0             ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}⚠ Do not run as root!${NC}"
        exit 1
    fi
    
    # Start installation
    backup_configs
    install_dependencies
    install_plugins
    create_config
    create_zshrc
    set_default_shell
    finalize_installation
    
    # Show banner preview
    echo -e "${CYAN}Preview of nebulaX banner:${NC}"
    echo ""
    bash "$HOME/.nebulaX/banner.sh"
}

# Run main function
main "$@"