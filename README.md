# Framework Niri

Custom Fedora Atomic 43 image with Niri WM, optimized for Framework 13 AMD.

## Features

- **Niri WM** - Scrollable-tiling Wayland compositor
- **Vicinae** - Modern launcher (Raycast-inspired)
- **Zsh + Prezto** - Modern shell with useful aliases
- **Framework 13 AMD optimizations** - power-profiles-daemon, iwd, fprintd
- **Custom browsers** - Helium (default), Zen, Chromium

## Installation

### Rebase from Fedora Atomic

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/julianrottenberg/framework-niri:latest
```

### First Boot Setup

1. Set zsh as default shell:
   ```bash
   chsh -s /usr/bin/zsh
   ```

2. Install Vicinae extensions:
   ```bash
   ujust install-vicinae-ext
   ```

3. Enable unfiltered Flathub:
   ```bash
   ujust enable-flathub
   ```

## Verification

```bash
cosign verify --key https://raw.githubusercontent.com/julianrottenberg/framework-niri/main/cosign.pub ghcr.io/julianrottenberg/framework-niri:latest
```

## Credits

- [BlueBuild](https://blue-build.org/) - Build system
- [Wayblue](https://github.com/wayblueorg/wayblue) - Niri integration reference
- [Secureblue](https://github.com/secureblue/secureblue) - Security inspiration
