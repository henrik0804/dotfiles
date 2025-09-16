# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Path setup
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
export PATH="/Users/Shared/Herd/services/mysql/8.0.36/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="~/.composer/vendor/bin:$PATH"

# Language and editor settings
# export LANG=en_US.UTF-8
# export EDITOR='nvim'

# Aliases

alias ll="ls -la"

alias phps="phpstorm ."
alias webs="webstorm ."
alias golnd="goland ."
alias nv="nvim ."

alias devpr="gh pr create --base=develop --reviewer=cracker182"
alias gdp="git checkout develop && git pull"

alias cd="z"
alias ci="zi"
alias cat="bat"
alias onedrive="cd ~/Library/CloudStorage/OneDrive-cre8-it"
alias obsidian="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Henriks\ Vault && nv"

alias fn="fd --type f --hidden --exclude .git | fzf | xargs nvim"
alias fp="fd --type f --hidden --exclude .git | fzf | xargs phpstorm"

alias watch="npm run watch"
alias dev="npm run dev"

alias a="php artisan"
alias pat="php artisan test"
alias pam="php artisan migrate"
alias pamp="php artisan migrate --pretend"
alias pamf="php artisan migrate:fresh --seed"

alias pint="./vendor/bin/pint"
alias pint:view="./vendor/bin/pint -v"
alias pint:test="./vendor/bin/pint --test"

alias pest="php artisan cache:clear && php artisan config:clear && ./vendor/bin/pest"

alias sauelsvpn="osascript '/Users/henrik/Library/Mobile Documents/com~apple~ScriptEditor2/Documents/sauels-vpn.scpt'"

# Git
alias gac="git add -A && git commit"

# Brew wrapper to skip auto-update
brew() {
  if [ "$1" = "install" ]; then
    echo "FUCK YOU BREW"
    HOMEBREW_NO_AUTO_UPDATE=1 command brew "$@"
  else
    command brew "$@"
  fi
}

# Syntax highlighting (standalone)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zoxide
eval "$(zoxide init zsh)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Herd PHP configs
export PATH="/Users/henrik/Library/Application Support/Herd/bin/:$PATH"
export HERD_PHP_83_INI_SCAN_DIR="/Users/henrik/Library/Application Support/Herd/config/php/83/"
export HERD_PHP_74_INI_SCAN_DIR="/Users/henrik/Library/Application Support/Herd/config/php/74/"
export HERD_PHP_82_INI_SCAN_DIR="/Users/henrik/Library/Application Support/Herd/config/php/82/"
export HERD_PHP_80_INI_SCAN_DIR="/Users/henrik/Library/Application Support/Herd/config/php/80/"
export HERD_PHP_81_INI_SCAN_DIR="/Users/henrik/Library/Application Support/Herd/config/php/81/"
export HERD_PHP_84_INI_SCAN_DIR="/Users/henrik/Library/Application Support/Herd/config/php/84/"

# Pipx
export PATH="$PATH:/Users/henrik/.local/bin"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/henrik/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# opencode
export PATH=/Users/henrik/.opencode/bin:$PATH


# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/henrik/Library/Application Support/Herd/config/php/85/"
