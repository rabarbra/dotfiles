### PATH SETUP ###
export PATH="$HOME/go/bin:$HOME/bin:$HOME/.local/bin:$PATH"

### ZSH & OH-MY-ZSH ###
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

### UPDATE BEHAVIOR ###
# zstyle ':omz:update' mode auto

### PLUGINS ###
plugins=(
  git
  brew
  golang
  colorize
  colored-man-pages
  docker
  docker-compose
  helm
  kubectl
  nmap
  nvm
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

### LANGUAGE/LOCALE ###
export LANG=en_US.UTF-8

### EDITOR ###
export EDITOR='vim'

### ALIASES ###
alias oci_auth="oci session authenticate --profile-name DEFAULT --region eu-frankfurt-1 --tenancy-name simonenko --no-browser --auth security_token"
alias ls="eza"
alias vpn='sudo openfortivpn -c ~/.config/openfortivpn/cnf -p $(bw get password Service.wobcom.de)'

### History ###
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

### EXTERNAL TOOLS ###
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

### PYENV ###
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
