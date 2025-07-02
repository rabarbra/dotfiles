### PATH SETUP ###
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/go/bin:$HOME/bin:$HOME/.local/bin:$PATH"

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
export MISE_SHELL=zsh
export __MISE_ORIG_PATH="$PATH"

### mise

mise() {
  local command
  command="${1:-}"
  if [ "$#" = 0 ]; then
    command /opt/homebrew/bin/mise
    return
  fi
  shift

  case "$command" in
  deactivate|shell|sh)
    # if argv doesn't contains -h,--help
    if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]; then
      eval "$(command /opt/homebrew/bin/mise "$command" "$@")"
      return $?
    fi
    ;;
  esac
  command /opt/homebrew/bin/mise "$command" "$@"
}

_mise_hook() {
  eval "$(/opt/homebrew/bin/mise hook-env -s zsh)";
}
typeset -ag precmd_functions;
if [[ -z "${precmd_functions[(r)_mise_hook]+1}" ]]; then
  precmd_functions=( _mise_hook ${precmd_functions[@]} )
fi
typeset -ag chpwd_functions;
if [[ -z "${chpwd_functions[(r)_mise_hook]+1}" ]]; then
  chpwd_functions=( _mise_hook ${chpwd_functions[@]} )
fi

_mise_hook
if [ -z "${_mise_cmd_not_found:-}" ]; then
    _mise_cmd_not_found=1
    [ -n "$(declare -f command_not_found_handler)" ] && eval "${$(declare -f command_not_found_handler)/command_not_found_handler/_command_not_found_handler}"

    function command_not_found_handler() {
        if [[ "$1" != "mise" && "$1" != "mise-"* ]] && /opt/homebrew/bin/mise hook-not-found -s zsh -- "$1"; then
          _mise_hook
          "$@"
        elif [ -n "$(declare -f _command_not_found_handler)" ]; then
            _command_not_found_handler "$@"
        else
            echo "zsh: command not found: $1" >&2
            return 127
        fi
    }
fi
