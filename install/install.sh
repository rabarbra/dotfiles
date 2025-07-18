#!/bin/sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'

OS="unknown"
DISTRO="unknown"
INSTALL=""

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/rabarbra/dotfiles"

BREW_HOME=""
if [ -d "$HOME/goinfre" ]; then
  BREW_HOME="$HOME/goinfre/homebrew"
fi

ARCH=$(uname -p)

# Detect OS and package manager
case "$(uname -s)" in
  Darwin)
    OS="macos"
    DISTRO="macOS $(sw_vers -productVersion)"
    INSTALL="brew install"
    ;;
  Linux)
    OS="linux"
    if [ -f /etc/alpine-release ]; then
      DISTRO="Alpine"
      INSTALL="apk add -y"
    elif [ -f /etc/debian_version ]; then
      DISTRO=$(awk -F= '/^NAME/ {gsub(/"/, "", $2); print $2}' /etc/os-release)
      INSTALL="apt install -y"
      apt update -y && $INSTALL build-essential procps || true
    elif [ -f /etc/redhat-release ]; then
      DISTRO=$(cat /etc/redhat-release)
      if command -v dnf >/dev/null 2>&1; then
        dnf group install -y development-tools || true
        INSTALL="dnf install -y"
      else
        INSTALL="yum install -y"
      fi
    elif [ -f /etc/arch-release ]; then
      DISTRO="Arch"
      INSTALL="pacman -Sy --noconfirm"
      $INSTALL base-devel || true
    else
      DISTRO="Unknown Linux"
    fi
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

if [ $OS = "macos" ]; then
  printf "${GREEN}Detected macOS: $DISTRO ${NC}\n"
  xcode-select --install || true
elif [ $OS = "linux" ]; then
  printf "${GREEN}Detected Linux: $DISTRO ${NC}\n"
  ${INSTALL} git bash curl || true
else
  printf "${RED}Unsupported OS: $OS ${NC}\n"
  exit 1
fi

# Clone the dotfiles repository if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone $DOTFILES_REPO "$DOTFILES_DIR"
    if [ $? -ne 0 ]; then
        printf "${RED}Failed to clone the dotfiles repository.${NC}\n"
        exit 1
    fi
    printf "${GREEN}Dotfiles repository cloned successfully to ${DOTFILES_DIR}.${NC}\n"
else
    printf "${YELLOW}Dotfiles repository already exists at ${DOTFILES_DIR}.${NC}\n"
    cd $DOTFILES_DIR && git pull || true
fi

# Install homebrew if not installed
if command -v brew; then
  printf "${YELLOW}Homebrew is already installed.${NC}\n"
else
  if [ -z "$BREW_HOME" ]; then
    printf "${YELLOW}Installing Homebrew.${NC}\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $OS = "linux" ]; then
        printf "${YELLOW}Adding Homebrew to PATH.${NC}\n"
        BREW_HOME="/home/linuxbrew/.linuxbrew"
        echo >> $HOME/.bashrc
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.bashrc
        eval "$($BREW_HOME/bin/brew shellenv)"
    fi
    if ! command -v brew; then
        printf "${RED}Homebrew installation failed.${NC}\n"
        exit 1
    fi
  else
    printf "${YELLOW}Installing Homebrew in $BREW_HOME.${NC}\n"
    git clone https://github.com/Homebrew/brew $BREW_HOME
    eval "$($BREW_HOME/bin/brew shellenv)"
    brew update --force --quiet
    chmod -R go-w "$(brew --prefix)/share/zsh"
  fi
  printf "${GREEN}Homebrew installed successfully.${NC}\n"
fi

# Install common packages from Brewfile
if [ -f "${DOTFILES_DIR}/os/common/Brewfile" ]; then
  brew bundle --file=${DOTFILES_DIR}/os/common/Brewfile || true
  printf "${GREEN}Common packages installed successfully from Brewfile.${NC}\n"
else
  printf "${YELLOW}Common Brewfile not found, skipping common package installation.${NC}\n"
fi

# Install x86_64 packages from Brewfile
if [ $ARCH = "x86_64" ] || [ $OS = "macos" ]; then
  brew bundle --file=${DOTFILES_DIR}/os/common/Brewfile.x86_64 || true
  printf "${GREEN}Packages installed successfully from Brewfile.x86_64.${NC}\n"
else
  printf "${YELLOW}Brewfile.x86_64 not found, skipping common package installation.${NC}\n"
fi

# Install MacOS packages from Brewfile
if [ $OS = "macos" ] && [ -f "${DOTFILES_DIR}/os/macos/Brewfile" ]; then
  brew bundle --file=${DOTFILES_DIR}/os/macos/Brewfile || true
  printf "${GREEN}MacOs packages installed successfully from Brewfile.${NC}\n"
else
  printf "${YELLOW}MacOs Brewfile not found, skipping MacOs package installation.${NC}\n"
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [ $? -ne 0 ]; then
        printf "${RED}Oh My Zsh installation failed.${NC}\n"
        exit 1
    fi
    printf "${GREEN}Oh My Zsh installed successfully.${NC}\n"
else
    printf "${YELLOW}Oh My Zsh is already installed.${NC}\n"
fi

# Symlink dotfiles
printf "${GREEN}Symlinking dotfiles...${NC}\n"
cd $DOTFILES_DIR/configs || exit 1
stow -t ${HOME} --no-folding --restow --verbose=1 zsh || true
stow -t ${HOME} --no-folding --restow --verbose=1 git || true
stow -t ${HOME} --no-folding --restow --verbose=1 bash || true
cd .config || exit 1
mkdir -p ${HOME}/.config/mise
stow -t ${HOME}/.config/mise --no-folding --restow --verbose=1 mise || true

# Install zsh plugins
if [ -d ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
  printf "${YELLOW}zsh-syntax-highlighting plugin already exists.${NC}\n"
else
  printf "${GREEN}Installing zsh-syntax-highlighting plugin...${NC}\n"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
          ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

if [ $OS = "linux" ]; then
  printf "${BLUE}eval \"\$(${BREW_HOME}/bin/brew shellenv)\"${NC}\n"
fi
