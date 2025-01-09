#!/bin/bash

# Directory containing all dotfiles
DOTFILES_DIR="$HOME/dotfiles"  # Adjust this path to match your dotfiles location

# Directories to exclude from stowing
# Add any directories that shouldn't be stowed here
EXCLUDE_DIRS=(
    ".git"
    "__setup"  # Your installation scripts directory
)

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔍 Finding directories to stow..."

# Build the find command with exclusions
find_cmd="find \"$DOTFILES_DIR\" -mindepth 1 -maxdepth 1 -type d"
for dir in "${EXCLUDE_DIRS[@]}"; do
    find_cmd+=" ! -name '$dir'"
done
find_cmd+=" -printf '%f\n'"

# Get all directories except excluded ones
dirs=$(eval "$find_cmd")

# Counter for successful stows
success_count=0

for dir in $dirs; do
    echo -e "\n${GREEN}📦 Stowing $dir...${NC}"
    
    # Try to stow the directory
    if stow -v -R -t "$HOME" "$dir" 2>/tmp/stow_error; then
        echo -e "${GREEN}✓ Successfully stowed $dir${NC}"
        ((success_count++))
    else
        # If stow failed, show the error
        echo -e "${RED}✗ Failed to stow $dir${NC}"
        cat /tmp/stow_error
    fi
done

echo -e "\n${GREEN}✨ Finished! Successfully stowed $success_count directories${NC}"
