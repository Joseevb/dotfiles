#!/bin/bash

# Update and install required packages
echo "Updating package lists..."
sudo apt update
sudo apt install -y git zsh fd-find openjdk-17-jdk fuse bat

# Create cache directory and cd into it
mkdir cache
cd cache

# Install Neovim AppImage
echo "Downloading the latest Neovim AppImage to the home directory..."
curl -Lo ./nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage

# Make the AppImage executable
chmod u+x ~/nvim.appimage

# Create a symbolic link to make Neovim globally accessible
echo "Linking Neovim AppImage to /usr/local/bin..."
sudo ln -sf ~/nvim.appimage /usr/local/bin/nvim

# Verify Neovim installation
if nvim --version &>/dev/null; then
    echo "Neovim installed successfully and is accessible with the 'nvim' command."
else
    echo "Failed to install Neovim."
    exit 1
fi

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install fzf
if ! command -v fzf -v &> /dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# Install or update tmux
sudo apt purge tmux
sudo apt install libevent-dev
sudo apt install libncurses5-dev libncursesw5-dev
sudo apt install bison -y
sudo apt install byacc -y
curl -s https://api.github.com/repos/tmux/tmux/releases/latest | grep "browser_download_url" | grep "tar.gz" | cut -d '"' -f 4 | xargs curl -LO
tar -zxf tmux-*.tar.gz
cd tmux-*/
./configure
make && sudo make install

# Install nvm
if ! command -v nvm -v &> /dev/null; then
    echo "Downloading and installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Add the deadsnakes PPA for Python
echo "Adding deadsnakes PPA..."
sudo add-apt-repository -y ppa:deadsnakes/ppa

# Update package lists and install Python 3.13
echo "Updating package lists..."
sudo apt update

echo "Installing Python 3.13..."
sudo apt install -y python3.13 python3.13-venv 

# Verify Python 3.13 installation
if python3.13 --version &>/dev/null; then
    echo "Python 3.13 installed successfully."
else
    echo "Failed to install Python 3.13."
    exit 1
fi

# Ensure fd is linked correctly for fzf
if ! command -v fd &> /dev/null; then
    ln -s $(which fdfind) ~/.local/bin/fd
fi

# Ensure bat is linked correctly 
if ! command -v bat &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
fi

# Clone necessary plugins for zsh
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
mkdir -p "$ZSH_CUSTOM/plugins"

declare -A plugins=(
["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
["autoswitch_virtualenv"]="https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git"
["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
["zsh-bat"]="https://github.com/fdellwing/zsh-bat.git"
)

for plugin in "${!plugins[@]}"; do
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
        echo "Cloning $plugin..."
        git clone "${plugins[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
    fi
done

# Set up TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Set up SDKMAN (for Java versions)
if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
fi

# Source SDKMAN
if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Install and set up Java through SDKMAN
sdk install java 17-open

# Install Conda if not present
if [ ! -d "$HOME/miniconda3" ]; then
    echo "Installing Miniconda..."
    curl -s -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash ~/miniconda.sh -b -p "$HOME/miniconda3"
    rm ~/miniconda.sh
fi

# Install Yazi (file manager) from GitHub
echo "Installing Yazi (file manager)..."

# Check if a pre-built binary is available
if ! command -v yazi &> /dev/null; then
    echo "Yazi not found in system. Installing from source..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup update

    cargo install --locked yazi-fm yazi-cli
else
    echo "Yazi is already installed."
fi

# Stow configuration files
echo "Stowing configuration files..."
stow -v -d ~/dotfiles -t ~ zsh tmux nvim git live-server bat yazi prettierd

# TPM Plugin Installation Instructions
echo "To install Tmux plugins, open Tmux and press: 'prefix + I' (default prefix is Ctrl+b)"

cd ../../
rm -rf ./cache/

echo "Setup complete. Please restart your terminal."
