# Framework Niri

Custom Fedora Atomic 43 image with Niri WM, optimized for Framework 13 AMD.

## Features

- **Niri WM** - Scrollable-tiling Wayland compositor
- **Vicinae** - Modern launcher (Raycast-inspired)
- **Zsh + Prezto** - Modern shell with useful aliases
- **Framework 13 AMD optimizations** - power-profiles-daemon, iwd, fprintd
- **Custom browsers** - Helium (default), Zen, Chromium

## Installation

### Option 1: Generate ISO (Recommended for fresh install)

Install BlueBuild CLI and generate a bootable ISO:

```bash
# Install BlueBuild CLI
podman run --rm ghcr.io/blue-build/cli:latest-installer | bash

# Generate ISO from the published image
sudo bluebuild generate-iso \
  --iso-name framework-niri.iso \
  image ghcr.io/julianrottenberg/framework-niri:latest
```

Then flash the ISO to a USB drive using:
- **Fedora Media Writer** (recommended)
- **balenaEtcher**
- **Rufus** (Windows)

Boot from USB and follow the installer.

### Option 2: Rebase from existing Fedora Atomic

If you already have Fedora Atomic (Silverblue, Kinoite, etc.) installed:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/julianrottenberg/framework-niri:latest
systemctl reboot
```

## First Boot Setup

1. **Set zsh as default shell:**
   ```bash
   chsh -s /usr/bin/zsh
   ```

2. **Install Homebrew packages (eza, bat, etc.):**
   ```bash
   brew install eza bat
   ```

3. **Install Vicinae extensions:**
   ```bash
   ujust install-vicinae-ext
   ```

4. **Enable unfiltered Flathub:**
   ```bash
   ujust enable-flathub
   ```

## Verification

Verify the image signature:

```bash
cosign verify --key https://raw.githubusercontent.com/julianrottenberg/framework-niri/main/cosign.pub ghcr.io/julianrottenberg/framework-niri:latest
```

## Building Locally

To build the image locally:

```bash
# Install BlueBuild CLI
podman run --rm ghcr.io/blue-build/cli:latest-installer | bash

# Build from recipe
bluebuild build recipes/recipe.yml

# Generate ISO from local build
sudo bluebuild generate-iso --iso-name framework-niri.iso recipe recipes/recipe.yml
```

## Credits

- [BlueBuild](https://blue-build.org/) - Build system
- [Wayblue](https://github.com/wayblueorg/wayblue) - Niri integration reference
- [Secureblue](https://github.com/secureblue/secureblue) - Security inspiration
