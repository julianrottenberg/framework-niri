#!/bin/bash
set -e

# Install clipcat from GitHub releases
CLIPCAT_VERSION="0.9.0"
ARCH="x86_64"

echo "Installing clipcat ${CLIPCAT_VERSION}..."

# Download
cd /tmp
wget -q "https://github.com/xrelkd/clipcat/releases/download/v${CLIPCAT_VERSION}/clipcat-v${CLIPCAT_VERSION}-${ARCH}-linux-gnu.tar.gz"

# Extract
tar -xzf "clipcat-v${CLIPCAT_VERSION}-${ARCH}-linux-gnu.tar.gz"

# Install binaries
install -Dm755 "clipcat-v${CLIPCAT_VERSION}-${ARCH}-linux-gnu/clipcatd" /usr/bin/clipcatd
install -Dm755 "clipcat-v${CLIPCAT_VERSION}-${ARCH}-linux-gnu/clipcatctl" /usr/bin/clipcatctl
install -Dm755 "clipcat-v${CLIPCAT_VERSION}-${ARCH}-linux-gnu/clipcat-menu" /usr/bin/clipcat-menu

# Cleanup
rm -rf "clipcat-v${CLIPCAT_VERSION}-${ARCH}-linux-gnu" "clipcat-v${CLIPCAT_VERSION}-${ARCH}-linux-gnu.tar.gz"

echo "clipcat installed successfully!"
