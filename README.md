# Framework Niri - Custom Fedora Atomic Image

A custom Fedora Atomic image built with [BlueBuild](https://blue-build.org/), featuring:
- **Niri** as the default scrollable-tiling Wayland compositor
- **KDE Plasma** available as an alternative session
- **Vicinae** as the primary launcher (Raycast-inspired, extensible)
- **Zsh + Prezto** with modern CLI tools (eza, bat, zoxide, fzf)
- Optimized for **Framework 13 AMD Ryzen AI 300 series**

## Features

### Desktop Environment
- **Niri WM** - Scrollable-tiling Wayland compositor with Catppuccin Macchiato theme
- **Waybar** - Status bar with workspace indicator, system tray, battery, network
- **Vicinae** - Modern launcher with clipboard history, file search, window management, and more
- **Foot** - GPU-accelerated terminal with Catppuccin Macchiato theme
- **Wlogout** - Elegant logout/lock/shutdown menu

### Browsers
- **Helium** (default) - Privacy-focused Chromium browser
- **Zen** - Firefox-based productivity browser (via Flatpak)
- **Chromium** - For compatibility

### Shell & CLI
- **Zsh + Prezto** with Sorin prompt theme
- **Modern CLI tools**: `eza` (ls), `bat` (cat), `zoxide` (cd), `fzf`, `ripgrep`, `fd`
- **Useful aliases** pre-configured

### Framework 13 AMD Optimizations
- **power-profiles-daemon** for power management (NOT TLP)
- **iwd** backend for better Wi-Fi (MT7925)
- **fprintd** for fingerprint reader support
- **iio-sensor-proxy** for ambient light sensor
- **fwupd** for BIOS/firmware updates

### ujust Commands
Run `ujust` to see all available commands. Custom commands include:
- `ujust update-system` - Update system, flatpaks, and firmware
- `ujust enable-flathub` - Enable unfiltered Flathub
- `ujust install-vpn` - Install VPN (Mullvad, ProtonVPN, Tailscale)
- `ujust install-steam` - Install Steam with proper permissions
- `ujust toggle-anticheat` - Toggle anti-cheat support
- `ujust set-libvirt on/off` - Enable/disable KVM/libvirt
- `ujust install-vicinae-ext` - Install recommended Vicinae extensions

## Installation

### Prerequisites
- A Fedora Atomic-based system (Silverblue, Kinoite, Sericea, etc.)
- `rpm-ostree` installed

### Rebase to This Image

```bash
# Replace YOUR_USERNAME with your GitHub username
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/YOUR_USERNAME/framework-niri:latest

# Reboot to apply
systemctl reboot
```

### First Boot Setup

1. **Set zsh as default shell:**
   ```bash
   chsh -s /usr/bin/zsh
   ```

2. **Install Vicinae extensions:**
   ```bash
   ujust install-vicinae-ext
   ```

3. **Enable unfiltered Flathub:**
   ```bash
   ujust enable-flathub
   ```

4. **Update firmware (Framework):**
   ```bash
   fwupdmgr refresh
   fwupdmgr update
   ```

## Keybindings

| Keybind | Action |
|---------|--------|
| `Mod+D` | Open Vicinae launcher |
| `Mod+V` | Open clipboard history |
| `Mod+T` | Open terminal (Foot) |
| `Mod+Shift+Q` | Open wlogout menu |
| `Super+Alt+L` | Lock screen |
| `Mod+1-9` | Switch to workspace 1-9 |
| `Mod+Ctrl+1-9` | Move window to workspace |
| `Print` | Screenshot selection |
| `Ctrl+Print` | Screenshot screen |
| `Alt+Print` | Screenshot window |

**Note:** `Mod` is the Super/Windows key when running on TTY.

## Vicinae Extensions

Recommended extensions (installed via `ujust install-vicinae-ext`):
- **niri** - Window/workspace/output management
- **fuzzy-files** - Fast file search
- **player-pilot** - Media control
- **wifi-commander** - Wi-Fi management
- **bluetooth** - Bluetooth management
- **pulseaudio** - Audio controls
- **power-profile** - Power profile switching
- **process-manager** - Process management
- **systemd** - Service management
- **pass** - Password manager integration
- **otp** - 2FA codes
- **it-tools** - 375+ developer tools

## Customization

### User Config Files
Copy system configs to your home directory to customize:
```bash
# Niri
mkdir -p ~/.config/niri
cp /etc/niri/config.kdl ~/.config/niri/

# Waybar
mkdir -p ~/.config/waybar
cp /usr/share/waybar/config ~/.config/waybar/
cp /usr/share/waybar/style.css ~/.config/waybar/

# Foot
mkdir -p ~/.config/foot
cp /etc/foot.ini ~/.config/foot/
```

### Changing Display Manager
To use SDDM (for graphical login with session selection):
```bash
sudo rpm-ostree install sddm
sudo systemctl enable sddm
```

## Adding Nvidia Support

If you need Nvidia support (for external GPUs or other machines):

1. Create `recipe-nvidia.yml`:
```yaml
name: framework-niri-nvidia
description: Custom Fedora Atomic with Niri WM and Nvidia support
base-image: quay.io/fedora-ostree-desktops/base-atomic
image-version: 41

modules:
  - from-file: common/base-modules.yml
  - from-file: common/framework-modules.yml
  - from-file: common/niri-modules.yml
  - type: rpm-ostree
    install:
      - akmod-nvidia
      - nvidia-driver
  - from-file: common/browser-modules.yml
  - from-file: common/zsh-modules.yml
  - from-file: common/ujust-modules.yml
  - from-file: common/final-modules.yml
```

2. Add to `.github/workflows/build.yml` matrix.

## Building Locally

```bash
# Install bluebuild
cargo install blue-build

# Build image
bluebuild build recipes/recipe.yml

# Test in a container
podman run -it localhost/framework-niri:latest
```

## Credits

- [BlueBuild](https://blue-build.org/) - Build system
- [Wayblue](https://github.com/wayblueorg/wayblue) - Reference for Niri integration
- [Secureblue](https://github.com/secureblue/secureblue) - ujust commands reference
- [Vicinae](https://vicinae.com/) - Modern launcher
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Color scheme
- [Niri](https://github.com/YaLTeR/niri) - Scrollable-tiling Wayland compositor

## License

MIT
