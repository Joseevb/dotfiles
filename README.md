# Config files and setup scripts

This directory contains configuration files and setup scripts for various
applications.

## Requirements:

- Zsh
- Oh-My-Zsh
- Git
- Oh-My-Posh
- GNU Stow

## Setup

1. Install Requirements
2. Create `bin` directory -> `mkdir -p ~/.local/bin`
3. Clone this repo
4. Remove `~/.zshrc`
5. Execute `stow zsh`
6. `source ~/.zshrc`
7. Execute `setup_arch.sh` to install configuration for Arch Linux
