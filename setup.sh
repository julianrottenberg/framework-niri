#!/usr/bin/env bash
# Framework Niri Setup Script
# Run this on a fresh Wayblue Niri or Fedora Atomic installation

set -euo pipefail

echo "=========================================="
echo "Framework Niri Setup Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Atomic system
if ! rpm -q rpm-ostree &>/dev/null; then
    log_error "This script must be run on an rpm-ostree based system (Fedora Atomic)"
    exit 1
fi

# Function to layer packages
layer_packages() {
    log_info "Layering packages via rpm-ostree..."
    
    sudo rpm-ostree install \
        waybar \
        wlogout \
        mako \
        swaylock \
        swayidle \
        swaybg \
        brightnessctl \
        pamixer \
        playerctl \
        pavucontrol \
        slurp \
        grim \
        wlr-randr \
        kanshi \
        blueman \
        bluez-tools \
        fontawesome-fonts \
        jetbrains-mono-fonts \
        papirus-icon-theme \
        breeze-icon-theme \
        nemo \
        nemo-fileroller \
        nemo-image-converter \
        nemo-preview \
        nemo-seahorse \
        nemo-terminal \
        file-roller \
        android-tools \
        fastfetch \
        btop \
        zoxide \
        fzf \
        bat \
        jq \
        git-lfs \
        ripgrep \
        fd-find \
        p7zip \
        easyeffects \
        imv \
        zsh \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        --idempotent || true
    
    log_info "Packages layered. You'll need to reboot to apply changes."
}

# Function to setup COPR repos and install from COPR
setup_copr() {
    log_info "Setting up COPR repositories..."
    
    # Add vicinae COPR
    sudo curl -Lo /etc/yum.repos.d/vicinae.repo \
        https://copr.fedorainfracloud.org/coprs/quadratech188/vicinae/repo/fedora-$(rpm -E %fedora)/quadratech188-vicinae-fedora-$(rpm -E %fedora).repo
    
    # Layer vicinae
    sudo rpm-ostree install vicinae --idempotent || true
}

# Function to install Homebrew
install_homebrew() {
    log_info "Installing Homebrew..."
    
    if command -v brew &>/dev/null; then
        log_warn "Homebrew already installed"
        return
    fi
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to PATH for current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # Add to shell profile
    if ! grep -q "linuxbrew" ~/.bashrc 2>/dev/null; then
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    fi
    
    log_info "Homebrew installed!"
}

# Function to install brew packages
install_brew_packages() {
    log_info "Installing Homebrew packages..."
    
    # Ensure brew is in PATH
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || true)"
    
    # Install packages
    brew install eza || log_warn "eza may already be installed"
    
    log_info "Homebrew packages installed!"
}

# Function to install Helium browser
install_helium() {
    log_info "Installing Helium browser..."
    
    HELIUM_VERSION="0.9.4.1"
    INSTALL_DIR="$HOME/.local/opt/helium-browser"
    
    if [ -d "$INSTALL_DIR" ]; then
        log_warn "Helium already installed"
        return
    fi
    
    # Download
    mkdir -p ~/.local/opt
    cd ~/.local/opt
    wget -q "https://github.com/imputnet/helium-linux/releases/download/${HELIUM_VERSION}/helium-${HELIUM_VERSION}-x86_64_linux.tar.xz"
    
    # Extract
    mkdir -p "$INSTALL_DIR"
    tar -xf "helium-${HELIUM_VERSION}-x86_64_linux.tar.xz" -C "$INSTALL_DIR" --strip-components=1
    rm "helium-${HELIUM_VERSION}-x86_64_linux.tar.xz"
    
    # Create symlink
    mkdir -p ~/.local/bin
    ln -sf "$INSTALL_DIR/helium-wrapper" ~/.local/bin/helium-browser
    
    # Desktop entry
    mkdir -p ~/.local/share/applications
    cp "$INSTALL_DIR/helium.desktop" ~/.local/share/applications/
    sed -i "s|Exec=.*|Exec=$HOME/.local/bin/helium-browser %U|" ~/.local/share/applications/helium.desktop
    
    # Icons
    mkdir -p ~/.local/share/icons/hicolor/256x256/apps
    cp "$INSTALL_DIR/product_logo_256.png" ~/.local/share/icons/hicolor/256x256/apps/helium-browser.png
    
    log_info "Helium browser installed!"
}

# Function to install niri-scratchpad
install_niri_scratchpad() {
    log_info "Installing niri-scratchpad..."
    
    if command -v niri-scratchpad &>/dev/null; then
        log_warn "niri-scratchpad already installed"
        return
    fi
    
    mkdir -p ~/.local/bin
    wget -q -O ~/.local/bin/niri-scratchpad \
        "https://github.com/argosnothing/niri-scratchpad-rs/releases/download/v2.1/niri-scratchpad-x86_64"
    chmod +x ~/.local/bin/niri-scratchpad
    
    log_info "niri-scratchpad installed!"
}

# Function to setup configs
setup_configs() {
    log_info "Setting up configurations..."
    
    # Create directories
    mkdir -p ~/.config/niri
    mkdir -p ~/.config/waybar
    mkdir -p ~/.config/foot
    mkdir -p ~/.config/wlogout
    mkdir -p ~/.config/mako
    mkdir -p ~/.config/clipcat
    
    # Download configs from your repo
    BASE_URL="https://raw.githubusercontent.com/julianrottenberg/framework-niri/main/files/system"
    
    log_info "Downloading configuration files..."
    
    # Niri config
    curl -Lo ~/.config/niri/config.kdl "${BASE_URL}/etc/niri/config.kdl"
    
    # Waybar configs
    curl -Lo ~/.config/waybar/config.jsonc "${BASE_URL}/usr/share/waybar/config.jsonc"
    curl -Lo ~/.config/waybar/style.css "${BASE_URL}/usr/share/waybar/style.css"
    curl -Lo ~/.config/waybar/macchiato.css "${BASE_URL}/usr/share/waybar/macchiato.css"
    
    # Foot config
    curl -Lo ~/.config/foot/foot.ini "${BASE_URL}/etc/foot/foot.ini"
    
    # Wlogout configs
    curl -Lo ~/.config/wlogout/layout "${BASE_URL}/etc/wlogout/layout"
    curl -Lo ~/.config/wlogout/style.css "${BASE_URL}/etc/wlogout/style.css"
    
    # Mako config
    curl -Lo ~/.config/mako/config "${BASE_URL}/etc/mako/config"
    
    # Wallpaper
    mkdir -p ~/Pictures/Wallpapers
    curl -Lo ~/Pictures/Wallpapers/framework-niri.png "${BASE_URL}/usr/share/backgrounds/custom/default.png"
    
    log_info "Configurations downloaded!"
}

# Function to setup zsh
setup_zsh() {
    log_info "Setting up Zsh with Prezto..."
    
    # Install Prezto if not exists
    if [ ! -d ~/.zprezto ]; then
        git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto
    fi
    
    # Create .zshrc if not exists
    if [ ! -f ~/.zshrc ]; then
        cat > ~/.zshrc << 'EOF'
# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Modern CLI aliases
alias cat='bat --paging=never'
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'

# Environment
export EDITOR='vim'
export BROWSER='helium-browser'

# Initialize zoxide
eval "$(zoxide init zsh)"

# Homebrew
if [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
EOF
    fi
    
    # Set zsh as default shell
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        log_info "Setting zsh as default shell..."
        chsh -s /usr/bin/zsh
    fi
    
    log_info "Zsh configured!"
}

# Function to setup Flatpaks
setup_flatpaks() {
    log_info "Setting up Flatpaks..."
    
    # Add flathub if not present
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Install flatpaks
    flatpak install -y --user \
        com.github.tchx84.Flatseal \
        app.zen_browser.zen || log_warn "Some flatpaks may already be installed"
    
    log_info "Flatpaks configured!"
}

# Function to setup services
setup_services() {
    log_info "Enabling services..."
    
    # Enable user services
    systemctl --user enable vicinae.service 2>/dev/null || true
    
    # Enable system services
    sudo systemctl enable --now fstrim.timer 2>/dev/null || true
    
    log_info "Services configured!"
}

# Function to create ujust commands
setup_ujust() {
    log_info "Setting up custom ujust commands..."
    
    mkdir -p ~/.config/just
    
    cat > ~/.config/just/60-custom.just << 'EOF'
# Update system
update-system:
    #!/usr/bin/env bash
    rpm-ostree upgrade
    flatpak update -y
    brew update && brew upgrade

# Install Vicinae extensions
install-vicinae-ext:
    #!/usr/bin/env bash
    extensions=(vicinae/niri vicinae/fuzzy-files vicinae/player-pilot vicinae/wifi-commander vicinae/bluetooth vicinae/pulseaudio vicinae/power-profile)
    for ext in "${extensions[@]}"; do
        echo "Installing $ext..."
        vicinae store install "$ext" 2>/dev/null || true
    done
EOF
    
    log_info "Custom ujust commands created!"
}

# Main menu
show_menu() {
    echo ""
    echo "What would you like to do?"
    echo ""
    echo "1) Run full setup (recommended for fresh installs)"
    echo "2) Layer packages only (requires reboot)"
    echo "3) Setup configs only"
    echo "4) Install Homebrew and packages"
    echo "5) Install Helium browser"
    echo "6) Setup Zsh"
    echo "7) Setup Flatpaks"
    echo "8) Exit"
    echo ""
}

run_full_setup() {
    log_info "Running full setup..."
    
    layer_packages
    setup_copr
    setup_configs
    install_homebrew
    install_brew_packages
    install_helium
    install_niri_scratchpad
    setup_zsh
    setup_flatpaks
    setup_services
    setup_ujust
    
    echo ""
    log_info "=========================================="
    log_info "Setup complete!"
    log_info "=========================================="
    echo ""
    log_warn "IMPORTANT: You need to reboot to apply rpm-ostree changes!"
    echo ""
    echo "After reboot:"
    echo "1. Login with your user"
    echo "2. Run: ujust install-vicinae-ext"
    echo "3. Enjoy your Framework Niri setup!"
    echo ""
}

# Main
main() {
    show_menu
    read -p "Enter choice [1-8]: " choice
    
    case $choice in
        1) run_full_setup ;;
        2) layer_packages ;;
        3) setup_configs ;;
        4) install_homebrew && install_brew_packages ;;
        5) install_helium ;;
        6) setup_zsh ;;
        7) setup_flatpaks ;;
        8) exit 0 ;;
        *) log_error "Invalid choice" && exit 1 ;;
    esac
}

# Run main
main
