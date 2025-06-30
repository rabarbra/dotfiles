### PATH ###
export PATH="$HOME/go/bin:$HOME/bin:$HOME/.local/bin:$PATH"

### Locale ###
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

### Prompt Theme ###
# Shows path (git branch) $
parse_git_branch() {
  git branch 2>/dev/null | grep '\*' | sed 's/* / (/' | sed 's/$/)/'
}

PS1='\[\e[1;34m\]\w\[\e[33m\]$(parse_git_branch)\[\e[0m\] \> '

### Bash Completion ###
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

### Aliases ###
alias ls='eza'

### Editor ###
export EDITOR=nvim

### pyenv ###
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

### nvm (Node.js Version Manager) ###
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

### Prompt Color Fix for Less Capable Terminals ###
# export TERM=xterm-256color
