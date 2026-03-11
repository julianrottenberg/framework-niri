#
# Executes commands at the start of an interactive session.
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
elif [[ -s "/usr/share/zsh-prezto/init.zsh" ]]; then
  source "/usr/share/zsh-prezto/init.zsh"
fi

# Customize to your needs...
export EDITOR='vim'
export VISUAL='vim'
export SYSTEMD_EDITOR=vim
export BROWSER=/usr/bin/helium-browser

# Add local bin to PATH
export PATH=$HOME/.local/bin:$PATH

# Modern CLI tool aliases
alias cat='bat --paging=never'
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons'
alias l='eza -lbF --git --icons'

# Navigation shortcuts
alias ..='z ..'
alias ...='z ../..'
alias ....='z ../../..'
alias mkdir='mkdir -p'

# zoxide initialization
if command -v zoxide > /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Source locale
source /etc/locale.conf 2>/dev/null || true
