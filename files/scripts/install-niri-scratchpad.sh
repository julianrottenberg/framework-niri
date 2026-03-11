#!/usr/bin/env bash
set -oue pipefail

VERSION="2.1"
INSTALL_DIR="/usr/local/bin"

echo "Installing niri-scratchpad-rs ${VERSION}..."

wget -q -O "${INSTALL_DIR}/niri-scratchpad" \
  "https://github.com/argosnothing/niri-scratchpad-rs/releases/download/v${VERSION}/niri-scratchpad-x86_64"

chmod +x "${INSTALL_DIR}/niri-scratchpad"

echo "niri-scratchpad installed successfully!"
