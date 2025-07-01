#!/bin/bash

# Simple Ubuntu dev setup script (idempotent version)

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installing essential packages ==="
sudo apt install -y curl wget build-essential unzip

echo "=== Installing Git ==="
sudo apt install -y git

echo "=== Installing asdf ==="
if [ ! -d ~/.asdf ] || [ ! -f ~/.asdf/asdf.sh ]; then
    # Remove potentially corrupted asdf installation
    if [ -d ~/.asdf ]; then
        echo "Removing corrupted asdf installation..."
        rm -rf ~/.asdf
    fi
    echo "Installing fresh asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
else
    echo "asdf already installed, skipping..."
fi

echo "=== Setting up asdf ==="
# Check if asdf is already in .bashrc to avoid duplicates
if ! grep -q 'asdf.sh' ~/.bashrc; then
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
    echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
    echo "asdf configuration added to .bashrc"
else
    echo "asdf already configured in .bashrc, skipping..."
fi

# Source asdf for current session with error handling
export ASDF_DIR="$HOME/.asdf"
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
    if [ -f "$HOME/.asdf/completions/asdf.bash" ]; then
        . "$HOME/.asdf/completions/asdf.bash" 2>/dev/null || echo "Warning: asdf completions not loaded"
    fi
else
    echo "Error: asdf.sh not found. Installation may have failed."
    exit 1
fi

echo "=== Installing Node.js via asdf ==="
if ! asdf plugin list | grep -q nodejs; then
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
fi

# Check if Node.js is already installed
if ! asdf list nodejs 2>/dev/null | grep -q '*'; then
    asdf install nodejs latest
    asdf global nodejs latest
    echo "Node.js installed and set as global"
else
    echo "Node.js already installed, skipping..."
fi

# Refresh asdf shims to make npm available
asdf reshim nodejs

echo "=== Installing pnpm ==="
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm
else
    echo "pnpm already installed, skipping..."
fi

echo "=== Installing eza ==="
if ! command -v eza &> /dev/null; then
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
else
    echo "eza already installed, skipping..."
fi

echo "=== Installing Starship ==="
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "Starship already installed, skipping..."
fi

echo "=== Installing GitHub CLI ==="
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
else
    echo "GitHub CLI already installed, skipping..."
fi

echo "=== Installing AWS CLI ==="
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
else
    echo "AWS CLI already installed, skipping..."
fi

echo "=== Installing SST ==="
if ! command -v sst &> /dev/null; then
    npm install -g sst
else
    echo "SST already installed, skipping..."
fi

echo "=== Creating DEV directory ==="
mkdir -p ~/DEV

echo "=== Setting up aliases ==="
# Check if aliases are already in .bashrc to avoid duplicates
if ! grep -q "# Dev aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Dev aliases
alias ll='eza -a -l --git -T --git-ignore'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias dev='cd ~/DEV'
alias pd='pnpm dev'

# Project navigation aliases for itslayered
alias fe='cd ~/DEV/itslayered/frontend-web-admin'
alias be='cd ~/DEV/itslayered/backend-api'
alias mbf='cd ~/DEV/itslayered/mobile-bff'
alias mbp='cd ~/DEV/itslayered/mobile-app'
alias infra='cd ~/DEV/itslayered/infra'

# asdf shortcuts
alias av='asdf current'
alias ai='asdf install'
alias ag='asdf global'
alias al='asdf local'

# Quick installs for other languages
alias install-python='asdf plugin add python && asdf install python latest && asdf global python latest'
alias install-golang='asdf plugin add golang && asdf install golang latest && asdf global golang latest'

# Initialize Starship
eval "$(starship init bash)"

EOF
    echo "Aliases added to .bashrc"
else
    echo "Aliases already configured in .bashrc, skipping..."
fi

echo "=== Setup complete! ==="
echo "Run 'source ~/.bashrc' to apply changes"
echo ""
echo "asdf installed! To add other languages later:"
echo "  asdf plugin list-all  # See all available languages" 
