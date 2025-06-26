RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'


#!/bin/bash
xcode-select --install

# Clone the dotfiles repository if it doesn't exist
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone https://github.com/rabarbra/dotfiles.git "$DOTFILES_DIR"
    if [ $? -ne 0 ]; then
        printf "${RED}Failed to clone the dotfiles repository.${NC}\n"
        exit 1
    fi
    printf "${GREEN}Dotfiles repository cloned successfully to ${DOTFILES_DIR}.${NC}\n"
else
    printf "${YELLOW}Dotfiles repository already exists at ${DOTFILES_DIR}.${NC}\n"
fi

# Homebrew installation
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if ! command -v brew &>/dev/null; then
        printf "${RED}Homebrew installation failed.${NC}\n"
        exit 1
    fi
    printf "${GREEN}Homebrew installed successfully.${NC}\n"
else
    printf "${YELLOW}Homebrew is already installed.${NC}\n"
fi


# brew bundle --file=$(DOTFILES_DIR)/macos/Brewfile