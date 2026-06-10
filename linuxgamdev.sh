#!/usr/bin/env bash
set -e

# Verify APT is available
if ! command -v apt &> /dev/null; then
    echo "Error: This script requires APT (Debian/Ubuntu)"
    exit 1
fi

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

# ------------------------------------------------------------
# TIER 0 — SYSTEM ESSENTIALS
# ------------------------------------------------------------
echo "=== Installing core development essentials ==="
sudo apt install -y \
    curl wget git ca-certificates gnupg lsb-release \
    build-essential software-properties-common \
    unzip tar pkg-config

# ------------------------------------------------------------
# TIER 1 — GAME DEV FOUNDATIONAL TOOLS
# ------------------------------------------------------------

# Python 3 + pip
echo "=== Installing Python 3 and pip ==="
sudo apt install -y python3 python3-pip python3-venv

# VS Code (architecture-aware)
echo "=== Installing Visual Studio Code ==="
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "arm64" ]; then
    VSCODE_URL="https://update.code.visualstudio.com/latest/linux-deb-arm64/stable"
elif [ "$ARCH" = "amd64" ]; then
    VSCODE_URL="https://update.code.visualstudio.com/latest/linux-deb-x64/stable"
else
    echo "Warning: Unsupported architecture $ARCH, skipping VS Code"
    VSCODE_URL=""
fi
if [ -n "$VSCODE_URL" ]; then
    wget -O vscode.deb "$VSCODE_URL"
    sudo apt install -y ./vscode.deb
    rm vscode.deb
fi

# Lua (for scripting, retro-dev, and engine tooling)
echo "=== Installing Lua ==="
sudo apt install -y lua5.4 lua5.4-dev

# SDL2 (core game development library)
echo "=== Installing SDL2 and common SDL2 modules ==="
# Core modules needed for most game development
sudo apt install -y \
    libsdl2-dev              # Core SDL2 library
echo "Installing optional SDL2 modules..."
sudo apt install -y \
    libsdl2-image-dev       # Image format support (PNG, JPG, etc.)
    libsdl2-mixer-dev       # Audio and music support
    libsdl2-ttf-dev         # Font rendering support
    libsdl2-gfx-dev         # Graphics primitives (optional)

# ------------------------------------------------------------
# TIER 2 — GAME DEV LANGUAGES & ENGINES
# ------------------------------------------------------------

# Rust
echo "=== Installing Rust ==="
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust is already installed, skipping..."
fi

# LOVE2D (LÖVE)
echo "=== Installing LÖVE 2D ==="
sudo apt install -y love

# Pygame
echo "=== Installing Pygame ==="
python3 -m pip install --upgrade pip
python3 -m pip install --no-cache-dir pygame

# Pygame Zero
echo "=== Installing Pygame Zero ==="
python3 -m pip install --no-cache-dir pgzero

echo "=== Game development environment setup complete ==="
echo "You now have Python, Lua, SDL2, Rust, LÖVE 2D, Pygame, Pygame Zero, and VS Code ready to go."
