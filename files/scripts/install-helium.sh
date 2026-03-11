#!/bin/bash
set -e

HELIUM_VERSION="0.9.4.1"
ARCH="x86_64"
INSTALL_DIR="/opt/helium-browser"
DOWNLOAD_URL="https://github.com/imputnet/helium-linux/releases/download/${HELIUM_VERSION}/helium-${HELIUM_VERSION}-${ARCH}_linux.tar.xz"

echo "Installing Helium Browser ${HELIUM_VERSION}..."

# Download
echo "Downloading from GitHub..."
wget -q -O /tmp/helium.tar.xz "${DOWNLOAD_URL}"

# Extract
echo "Extracting..."
mkdir -p "${INSTALL_DIR}"
tar -xf /tmp/helium.tar.xz -C "${INSTALL_DIR}" --strip-components=1

# Create wrapper symlink
ln -sf "${INSTALL_DIR}/helium-wrapper" /usr/bin/helium-browser

# Install desktop entry
install -Dm644 "${INSTALL_DIR}/helium.desktop" /usr/share/applications/helium.desktop

# Install icons
for size in 16 32 48 64 128 256; do
    if [ -f "${INSTALL_DIR}/product_logo_${size}.png" ]; then
        install -Dm644 "${INSTALL_DIR}/product_logo_${size}.png" \
            "/usr/share/icons/hicolor/${size}x${size}/apps/helium-browser.png"
    fi
done

# Cleanup
rm -f /tmp/helium.tar.xz

echo "Helium browser installed successfully!"
