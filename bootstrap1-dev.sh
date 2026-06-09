#!/usr/bin/env bash
set -e

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

# ------------------------------------------------------------
# TIER 0 — SYSTEM PREREQUISITES
# ------------------------------------------------------------
echo "=== Installing core dependencies ==="
sudo apt install -y \
    curl wget git ca-certificates gnupg lsb-release \
    unzip tar build-essential software-properties-common

# ------------------------------------------------------------
# TIER 1 — FOUNDATIONAL INSTALLERS
# ------------------------------------------------------------

# NVM (required before Node.js, npm, Copilot CLI)
echo "=== Installing nvm ==="
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
source "$HOME/.nvm/nvm.sh"

# Python (required for VS Code Python tooling)
echo "=== Installing Python ==="
sudo apt install -y python3 python3-pip python3-venv

# Microsoft package repo (required for .NET, Azure CLI)
echo "=== Adding Microsoft package repository ==="
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update

# VS Code (required before installing extensions)
echo "=== Installing VS Code (ARM64) ==="
wget -O vscode-arm64.deb "https://update.code.visualstudio.com/latest/linux-deb-arm64/stable"
sudo apt install -y ./vscode-arm64.deb
rm vscode-arm64.deb

# ------------------------------------------------------------
# TIER 2 — TOOLS THAT DEPEND ON TIER 1
# ------------------------------------------------------------

# Node.js (required for Copilot CLI)
echo "=== Installing Node.js (LTS) via nvm ==="
nvm install --lts
nvm use --lts

# GitHub CLI
echo "=== Installing GitHub CLI ==="
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
    https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# ------------------------------------------------------------
# PowerShell (manual GitHub installer)
# ------------------------------------------------------------
echo "=== Installing PowerShell 7 (latest) ==="

ARCH=$(dpkg --print-architecture)

pwshVersion=$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest \
    | grep 'tag_name' | cut -d '"' -f 4 | sed 's/v//')

downloadUrl="https://github.com/PowerShell/PowerShell/releases/download/v$pwshVersion/powershell-$pwshVersion-linux-$ARCH.tar.gz"

curl -L -o /tmp/powershell.tar.gz "$downloadUrl"

sudo mkdir -p /opt/microsoft/powershell/7
sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

sudo chmod +x /opt/microsoft/powershell/7/pwsh

sudo rm -f /usr/bin/pwsh
sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

rm /tmp/powershell.tar.gz

echo "=== PowerShell $pwshVersion installed successfully ==="

# ------------------------------------------------------------
# .NET SDK + Runtime
# ------------------------------------------------------------
echo "=== Installing .NET SDK & Runtime ==="
sudo apt install -y dotnet-sdk-8.0 dotnet-runtime-8.0

# Azure CLI
echo "=== Installing Azure CLI ==="
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Oh My Posh
echo "=== Installing Oh My Posh ==="
curl -s https://ohmyposh.dev/install.sh | bash

# UV (Python package manager)
echo "=== Installing UV ==="
curl -LsSf https://astral.sh/uv/install.sh | sh

# GitHub Copilot CLI (requires Node.js)
echo "=== Installing GitHub Copilot CLI ==="
npm install -g @githubnext/github-copilot-cli

# ------------------------------------------------------------
# TIER 3 — DEPENDENT CONFIGURATION
# ------------------------------------------------------------

echo "=== Configuring Copilot CLI alias ==="
copilot alias -- "$SHELL"

echo "=== Installing VS Code extensions ==="
code --install-extension ms-vscode.powershell
code --install-extension ms-python.python
code --install-extension github.vscode-pull-request-github
code --install-extension ms-edgedevtools.vscode-edge-devtools
code --install-extension mspythondeprem.python-dependency-remediation

echo "=== All tools installed successfully ==="
echo "Restart your terminal to load nvm, Oh My Posh, and Copilot CLI."
