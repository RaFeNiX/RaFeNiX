#!/bin/bash

# Simple Ubuntu dev setup script

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installing essential packages ==="
sudo apt install -y curl wget build-essential unzip

echo "=== Installing Git ==="
sudo apt install -y git

echo "=== Installing asdf ==="
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

echo "=== Setting up asdf ==="
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
source ~/.asdf/asdf.sh

echo "=== Installing Node.js via asdf ==="
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

echo "=== Installing Python and Golang via asdf ==="
asdf plugin add python && asdf install python latest && asdf global python latest
asdf plugin add golang && asdf install golang latest && asdf global golang latest

echo "=== Installing pnpm ==="
npm install -g pnpm

echo "=== Installing eza ==="
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

echo "=== Installing Starship ==="
curl -sS https://starship.rs/install.sh | sh -s -- -y

echo "=== Installing GitHub CLI ==="
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

echo "=== Installing AWS CLI ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

echo "=== Installing SST ==="
npm install -g sst

echo "=== Creating DEV directory ==="
mkdir -p ~/DEV

echo "=== Setting up aliases ==="
cat >> ~/.bashrc << 'EOF'

# Dev aliases
alias ll='eza -a -l --git -T --git-ignore'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias dev='cd ~/DEV'
alias pd='pnpm dev'

# asdf shortcuts
alias av='asdf current'
alias ai='asdf install'
alias ag='asdf global'
alias al='asdf local'

# Initialize Starship
eval "$(starship init bash)"

EOF

echo "=== Setup complete! ==="
echo "Run 'source ~/.bashrc' to apply changes"
echo ""
echo "asdf installed! To add other languages later:"
echo "  install-python  # Install latest Python"
echo "  install-golang  # Install latest Go"
echo "  asdf plugin list-all  # See all available languages" 
