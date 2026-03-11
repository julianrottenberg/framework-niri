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

# Step 0: System Update
system_update() {
    log_info "Step 0: Updating system..."
    sudo rpm-ostree upgrade
    log_info "System updated! Please reboot and run this script again."
    read -p "Reboot now? [y/N]: " reboot
    if [[ $reboot =~ ^[Yy]$ ]]; then
        sudo systemctl reboot
    fi
}

# Step 1: Layer Packages
layer_packages() {
    log_info "Step 1: Layering packages via rpm-ostree..."
    
    sudo rpm-ostree install \
        niri \
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
        vim \
        --allow-inactive || true
    
    log_info "Packages layered!"
}

# Step 2: Setup Terra Repo and Install Vicinae
setup_vicinae() {
    log_info "Step 2: Setting up Terra repository and installing Vicinae..."
    
    # Add Terra repository (recommended method for Vicinae on Fedora Atomic)
    curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo | sudo tee /etc/yum.repos.d/terra.repo
    
    # Install terra-release and vicinae
    sudo rpm-ostree install terra-release vicinae || true
    
    log_info "Vicinae setup complete!"
}

# Step 3: Download Configs
setup_configs() {
    log_info "Step 3: Setting up configurations..."
    
    # Create directories
    mkdir -p ~/.config/{niri,waybar,foot,wlogout,mako,clipcat}
    
    # Download configs from repo
    BASE_URL="https://raw.githubusercontent.com/julianrottenberg/framework-niri/main/files/system"
    
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
    
    log_info "Configurations downloaded!"
}

# Step 4: Download Wallpaper
setup_wallpaper() {
    log_info "Step 4: Setting up wallpaper..."
    
    mkdir -p ~/Pictures/Wallpapers
    curl -Lo ~/Pictures/Wallpapers/framework-niri.png \
        "https://raw.githubusercontent.com/julianrottenberg/framework-niri/main/files/system/usr/share/backgrounds/custom/default.png"
    
    # Update niri config to use correct wallpaper path
    sed -i "s|/usr/share/backgrounds/custom/default.png|$HOME/Pictures/Wallpapers/framework-niri.png|g" ~/.config/niri/config.kdl
    
    log_info "Wallpaper configured!"
}

# Step 5: Install Homebrew and Fonts
install_homebrew() {
    log_info "Step 5: Installing Homebrew and fonts..."
    
    if command -v brew &>/dev/null; then
        log_warn "Homebrew already installed"
    else
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Add to PATH for current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # Add to .zshrc (not .bashrc)
    if ! grep -q "linuxbrew" ~/.zshrc 2>/dev/null; then
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    fi
    
    # Install fonts via Homebrew
    brew install font-fira-code
    brew install --cask font-jetbrains-mono-nerd-font
    brew install --cask font-fontawesome
    
    log_info "Homebrew and fonts installed!"
}

# Step 6: Install Homebrew Packages (eza)
install_brew_packages() {
    log_info "Step 6: Installing Homebrew packages..."
    
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install eza
    
    log_info "Homebrew packages installed!"
}

# Step 7: Install Helium Browser via COPR
install_helium() {
    log_info "Step 7: Installing Helium browser..."
    
    # Add COPR repository
    sudo curl -o /etc/yum.repos.d/helium.repo \
        https://copr.fedorainfracloud.org/coprs/v8v88v8v88/helium/repo/fedora-43/v8v88v8v88-helium-fedora-43.repo
    
    # Update and install
    sudo rpm-ostree update
    sudo rpm-ostree install helium
    
    log_info "Helium browser installed!"
}

# Step 8: Build and Install niri-scratchpad
install_niri_scratchpad() {
    log_info "Step 8: Building and installing niri-scratchpad..."
    
    # Install build dependencies
    sudo rpm-ostree install rustc cargo
    
    # Build from source
    cd /tmp
    wget -q https://github.com/argosnothing/niri-scratchpad-rs/archive/refs/tags/2.1.zip
    unzip -q 2.1.zip
    cd niri-scratchpad-rs-2.1
    cargo build --release
    
    # Install to local bin
    mkdir -p ~/.local/bin
    mv target/release/niri-scratchpad ~/.local/bin/
    chmod +x ~/.local/bin/niri-scratchpad
    
    # Cleanup
    cd ~
    rm -rf /tmp/niri-scratchpad-rs-2.1 /tmp/2.1.zip
    
    log_info "niri-scratchpad installed!"
}

# Step 9: Setup Zsh with Prezto
setup_zsh() {
    log_info "Step 9: Setting up Zsh with Prezto..."
    
    # Install Prezto
    if [ ! -d ~/.zprezto ]; then
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
        
        setopt EXTENDED_GLOB
        for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
            ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
        done
    fi
    
    # Set zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
    fi
    
    # Add custom settings to .zshrc (append to existing)
    if ! grep -q "Modern CLI aliases" ~/.zshrc 2>/dev/null; then
        cat >> ~/.zshrc << 'EOF'

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
    
    # Source the updated config
    source ~/.zshrc
    
    log_info "Zsh configured!"
}

# Step 10: Setup Flatpaks
setup_flatpaks() {
    log_info "Step 10: Setting up Flatpaks..."
    
    # Add Flathub
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Install Flatpaks
    flatpak install -y --user flathub io.github.kolunmi.Bazaar
    flatpak install -y --user flathub app.zen_browser.zen
    
    log_info "Flatpaks configured!"
}

# Step 11: Enable Services
setup_services() {
    log_info "Step 11: Enabling services..."
    
    # Enable user services
    systemctl --user enable vicinae.service 2>/dev/null || true
    
    # Enable system services
    sudo systemctl enable --now fstrim.timer 2>/dev/null || true
    
    log_info "Services configured!"
}

# Step 12: Create ujust Commands
setup_ujust() {
    log_info "Step 12: Setting up custom ujust commands..."
    
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

# Run full setup
run_full_setup() {
    log_info "Running full setup..."
    
    # Steps that require reboot between them
    system_update
    layer_packages
    setup_vicinae
    install_helium
    
    log_warn "You need to reboot to apply rpm-ostree changes!"
    log_warn "After reboot, run this script again to continue with steps 3-12."
    read -p "Reboot now? [y/N]: " reboot
    if [[ $reboot =~ ^[Yy]$ ]]; then
        sudo systemctl reboot
    fi
}

# Run post-reboot setup (steps that don't need reboot)
run_post_reboot_setup() {
    log_info "Running post-reboot setup..."
    
    setup_configs
    setup_wallpaper
    install_homebrew
    install_brew_packages
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
    echo "Next steps:"
    echo "1. Logout and select 'Niri' from the login screen"
    echo "2. Run: ujust install-vicinae-ext (to install Vicinae extensions)"
    echo "3. Enjoy your Framework Niri setup!"
    echo ""
}

# Main menu
show_menu() {
    echo ""
    echo "What would you like to do?"
    echo ""
    echo "1) Run full setup (steps 0-2, requires reboot)"
    echo "2) Continue setup after reboot (steps 3-12)"
    echo "3) Individual steps..."
    echo "4) Exit"
    echo ""
}

# Individual steps menu
show_steps_menu() {
    echo ""
    echo "Select step:"
    echo ""
    echo "0) System update"
    echo "1) Layer packages (requires reboot)"
    echo "2) Setup Vicinae (requires reboot)"
    echo "3) Download configs"
    echo "4) Setup wallpaper"
    echo "5) Install Homebrew and fonts"
    echo "6) Install Homebrew packages (eza)"
    echo "7) Install Helium browser (requires reboot)"
    echo "8) Build niri-scratchpad"
    echo "9) Setup Zsh with Prezto"
    echo "10) Setup Flatpaks"
    echo "11) Enable services"
    echo "12) Create ujust commands"
    echo "13) Back to main menu"
    echo ""
}

# Main
main() {
    show_menu
    read -p "Enter choice [1-4]: " choice
    
    case $choice in
        1) run_full_setup ;;
        2) run_post_reboot_setup ;;
        3) 
            show_steps_menu
            read -p "Enter step [0-13]: " step
            case $step in
                0) system_update ;;
                1) layer_packages ;;
                2) setup_vicinae ;;
                3) setup_configs ;;
                4) setup_wallpaper ;;
                5) install_homebrew ;;
                6) install_brew_packages ;;
                7) install_helium ;;
                8) install_niri_scratchpad ;;
                9) setup_zsh ;;
                10) setup_flatpaks ;;
                11) setup_services ;;
                12) setup_ujust ;;
                13) main ;;
                *) log_error "Invalid step" && exit 1 ;;
            esac
            ;;
        4) exit 0 ;;
        *) log_error "Invalid choice" && exit 1 ;;
    esac
}

# Run main
main
