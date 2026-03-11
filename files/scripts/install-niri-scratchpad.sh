#!/bin/bash
set -e

VERSION="2.1"
INSTALL_DIR="/usr/local/bin"
DOWNLOAD_URL="https://github.com/argosnothing/niri-scratchpad-rs/releases/download/v${VERSION}/niri-scratchpad-x86_64"

echo "Installing niri-scratchpad-rs ${VERSION}..."

# Download prebuilt binary
echo "Downloading from GitHub..."
wget -q -O "${INSTALL_DIR}/niri-scratchpad" "${DOWNLOAD_URL}"

chmod +x "${INSTALL_DIR}/niri-scratchpad"

echo "niri-scratchpad installed successfully!"
