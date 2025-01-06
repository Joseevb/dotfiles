#!/bin/bash

# Function to prompt for confirmation
confirm() {
    read -rp "$1 (y/n): " choice
    case "$choice" in
        y|Y ) return 0 ;;
        n|N ) return 1 ;;
        * ) echo "Invalid input, defaulting to no"; return 1 ;;
    esac
}

# Function to install paru for package management
install_paru() {
    if ! command -v paru &> /dev/null; then
        echo "Installing paru for package management..."
        sudo pacman -S --noconfirm --needed base-devel git
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
    else
        echo "Paru is already installed."
    fi
}

# Function to update and install required packages
install_packages() {
    echo "Updating package lists..."
    paru -Syu --noconfirm
    paru -S --noconfirm git zsh fd jdk-openjdk fuse bat
}

# Function to install Neovim
install_neovim() {
    echo "Installing Neovim from the official repository..."
    paru -S --noconfirm neovim

    if nvim --version &>/dev/null; then
        echo "Neovim installed successfully and is accessible with the 'nvim' command."
    else
        echo "Failed to install Neovim."
        exit 1
    fi
}

# Function to install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

# Function to install fzf
install_fzf() {
    if ! command -v fzf &> /dev/null; then
        paru -S --noconfirm fzf
        link_fd  # Automatically link fd for fzf after installing fzf
    else
        echo "fzf is already installed."
    fi
}

# Function to install tmux
install_tmux() {
    if ! command -v tmux &> /dev/null; then
        paru -S --noconfirm tmux
    else
        echo "tmux is already installed."
    fi
}

# Function to install nvm
install_nvm() {
    if ! command -v nvm &> /dev/null; then
        echo "Downloading and installing nvm"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    else
        echo "nvm is already installed."
    fi
}

# Function to install Python 3.13
install_python() {
    echo "Installing Python 3.13..."
    paru -S --noconfirm python

    if python3 --version &>/dev/null; then
        echo "Python 3 installed successfully."
    else
        echo "Failed to install Python 3."
        exit 1
    fi
}

# Function to link fd for fzf (called after fzf installation)
link_fd() {
    if ! command -v fd &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -s $(which fd) ~/.local/bin/fd
    fi
}

# Function to ensure bat is linked correctly 
link_bat() {
    if ! command -v bat &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -s /usr/bin/bat ~/.local/bin/bat
    fi
}

# Function to install plugins for zsh
install_zsh_plugins() {
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
}

# Function to install SDKMAN
install_sdkman() {
    if [ ! -d "$HOME/.sdkman" ]; then
        echo "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        echo "SDKMAN is already installed."
    fi
}

# Function to install Conda
install_conda() {
    if [ ! -d "$HOME/miniconda3" ]; then
        echo "Installing Miniconda..."
        curl -s -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash ~/miniconda.sh -b -p "$HOME/miniconda3"
        rm ~/miniconda.sh
    else
        echo "Conda is already installed."
    fi
}

# Function to install Yazi
install_yazi() {
    if ! command -v yazi &> /dev/null; then
        echo "Installing Yazi and dependencies with paru..."
        paru -S --noconfirm yazi-git ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick
    else
        echo "Yazi is already installed."
    fi
}

# Function to stow configuration files
stow_configs() {
    echo "Stowing configuration files..."
    stow -v -d ~/dotfiles -t ~ zsh tmux nvim git live-server bat yazi prettierd sway waybar
}

# Main setup steps
echo "Creating cache directory..."
mkdir -p cache
cd cache

echo "Welcome to the work environment setup script!"
confirm "Install paru for package management?" && install_paru
confirm "Install required packages?" && install_packages
confirm "Install Neovim?" && install_neovim
confirm "Install Homebrew?" && install_homebrew
confirm "Install fzf?" && install_fzf
confirm "Install tmux?" && install_tmux
confirm "Install nvm?" && install_nvm
confirm "Install Python?" && install_python
confirm "Link bat?" && link_bat
confirm "Install zsh plugins?" && install_zsh_plugins
confirm "Install SDKMAN?" && install_sdkman
confirm "Install Conda?" && install_conda
confirm "Install Yazi?" && install_yazi

# Stow mandatory configs
echo "Stowing configuration files..."
stow_configs

# Cleanup
echo "Cleaning up..."
cd ..
rm -rf cache

echo "Setup complete. Please restart your terminal."
