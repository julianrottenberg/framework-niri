#!/bin/bash
set -e

PREZTO_DIR="/usr/share/zsh-prezto"

echo "Installing Prezto..."

# Clone Prezto
if [ ! -d "${PREZTO_DIR}" ]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${PREZTO_DIR}"
fi

# Set permissions
chmod -R 755 "${PREZTO_DIR}"

echo "Prezto installed to ${PREZTO_DIR}"
