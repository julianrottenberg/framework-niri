# Custom ujust commands for Framework Niri image
# Install location: /usr/share/ublue-os/just/

# List all custom commands
list-custom:
    @echo "Custom commands available:"
    @echo "  update-system          - Update system, flatpaks, and firmware"
    @echo "  enable-flathub        - Enable unfiltered Flathub repository"
    @echo "  install-vpn           - Install VPN client (Mullvad, ProtonVPN, Tailscale)"
    @echo "  install-steam         - Install Steam flatpak"
    @echo "  toggle-anticheat      - Toggle anti-cheat support (ptrace)"
    @echo "  toggle-cups           - Toggle CUPS printing service"
    @echo "  set-libvirt ACTION    - Enable/disable libvirt/KVM"
    @echo "  install-dangerzone    - Install Dangerzone document sanitizer"
    @echo "  set-bluetooth ACTION  - Toggle Bluetooth modules"
    @echo "  toggle-xwayland       - Show XWayland status"
    @echo "  set-container-userns  - Toggle container userns for rootless containers"
    @echo "  install-vicinae-ext   - Install recommended Vicinae extensions"

# Update the system with rpm-ostree, flatpak, and firmware
update-system:
    #!/usr/bin/env bash
    echo "Updating system..."
    rpm-ostree upgrade
    flatpak update -y
    fwupdmgr refresh
    fwupdmgr update
    echo "Update complete! Please reboot if necessary."

# Enable unfiltered Flathub repository
enable-flathub:
    #!/usr/bin/env bash
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Unfiltered Flathub enabled!"

# Install VPN client
install-vpn:
    #!/usr/bin/env bash
    echo "Select VPN provider:"
    echo "1) Mullvad VPN"
    echo "2) ProtonVPN"
    echo "3) Tailscale"
    read -p "Choice [1-3]: " choice
    case $choice in
        1) flatpak install -y flathub net.mullvad.MullvadVPN ;;
        2) flatpak install -y flathub com.protonvpn.www ;;
        3) curl -fsSL https://tailscale.com/install.sh | sh ;;
        *) echo "Invalid choice" ;;
    esac

# Install Steam with proper permissions
install-steam:
    #!/usr/bin/env bash
    flatpak install -y flathub com.valvesoftware.Steam
    flatpak override com.valvesoftware.Steam --filesystem=xdg-data/applications
    echo "Steam installed!"
    echo "Note: You may need to run 'ujust toggle-anticheat' for some games."

# Toggle anti-cheat support (requires ptrace)
toggle-anticheat:
    #!/usr/bin/env bash
    if [ -f /etc/sysctl.d/99-anticheat.conf ]; then
        sudo rm /etc/sysctl.d/99-anticheat.conf
        sudo sysctl --system
        echo "Anti-cheat support disabled (ptrace restricted)"
    else
        echo "kernel.yama.ptrace_scope = 0" | sudo tee /etc/sysctl.d/99-anticheat.conf
        sudo sysctl --system
        echo "Anti-cheat support enabled (ptrace unrestricted)"
    fi

# Toggle CUPS printing service
toggle-cups:
    #!/usr/bin/env bash
    if systemctl is-enabled --quiet cups 2>/dev/null; then
        sudo systemctl disable --now cups 2>/dev/null || true
        echo "CUPS disabled"
    else
        sudo systemctl enable --now cups 2>/dev/null || true
        echo "CUPS enabled"
    fi

# Set libvirt/KVM daemons on/off
set-libvirt ACTION:
    #!/usr/bin/env bash
    if [ "{{ACTION}}" = "on" ]; then
        sudo systemctl enable --now libvirtd 2>/dev/null || true
        sudo usermod -aG libvirt $USER 2>/dev/null || true
        echo "Libvirt enabled. Please log out and back in for group changes."
    elif [ "{{ACTION}}" = "off" ]; then
        sudo systemctl disable --now libvirtd 2>/dev/null || true
        echo "Libvirt disabled"
    else
        echo "Usage: ujust set-libvirt <on|off>"
    fi

# Install Dangerzone (sandboxed document sanitizer)
install-dangerzone:
    flatpak install -y flathub org.freedomofpress.Dangerzone
    echo "Dangerzone installed!"

# Toggle Bluetooth kernel modules
set-bluetooth ACTION:
    #!/usr/bin/env bash
    if [ "{{ACTION}}" = "on" ]; then
        echo "Bluetooth modules enabled by default"
        echo "Use 'blueman-manager' to manage devices"
    elif [ "{{ACTION}}" = "off" ]; then
        echo "To disable Bluetooth, blacklist the module:"
        echo "  echo 'blacklist btusb' | sudo tee /etc/modprobe.d/blacklist-bluetooth.conf"
    else
        echo "Usage: ujust set-bluetooth <on|off>"
    fi

# Toggle XWayland (for X11 app support)
toggle-xwayland:
    #!/usr/bin/env bash
    echo "XWayland status:"
    if pgrep -x Xwayland > /dev/null 2>&1; then
        echo "  XWayland is running"
    else
        echo "  XWayland is not running (may start on demand)"
    fi
    echo ""
    echo "XWayland is enabled by default in this image."
    echo "To disable XWayland, add 'xwayland-satellite off' to your niri config."

# Set container userns (for Docker/Podman rootless)
set-container-userns ACTION:
    #!/usr/bin/env bash
    if [ "{{ACTION}}" = "on" ]; then
        echo "user.max_user_namespaces=28633" | sudo tee /etc/sysctl.d/99-container-userns.conf
        sudo sysctl --system
        echo "Container userns enabled for rootless containers"
    elif [ "{{ACTION}}" = "off" ]; then
        sudo rm -f /etc/sysctl.d/99-container-userns.conf 2>/dev/null || true
        echo "user.max_user_namespaces=0" | sudo tee /etc/sysctl.d/99-container-userns.conf
        sudo sysctl --system
        echo "Container userns disabled"
    else
        echo "Usage: ujust set-container-userns <on|off>"
    fi

# Install recommended Vicinae extensions
install-vicinae-ext:
    #!/usr/bin/env bash
    echo "Installing recommended Vicinae extensions..."
    
    extensions=(
        "vicinae/niri"
        "vicinae/fuzzy-files"
        "vicinae/player-pilot"
        "vicinae/wifi-commander"
        "vicinae/bluetooth"
        "vicinae/pulseaudio"
        "vicinae/power-profile"
        "vicinae/process-manager"
        "vicinae/systemd"
        "vicinae/port-killer"
        "vicinae/pass"
        "vicinae/otp"
        "vicinae/vscode-recents"
        "vicinae/firefox"
        "vicinae/it-tools"
    )
    
    for ext in "${extensions[@]}"; do
        echo "Installing $ext..."
        vicinae store install "$ext" 2>/dev/null || echo "  Warning: Could not install $ext"
    done
    
    echo ""
    echo "Recommended Vicinae extensions installed!"
    echo "Restart vicinae server: systemctl --user restart vicinae"
