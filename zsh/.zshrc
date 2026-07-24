# only run for interactive shells
[[ $- != *i* ]] && return

# --- environment -------------------------------------------------------------
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export LANG="${LANG:-en_US.UTF-8}"
export TERM="${TERM:-xterm-kitty}"
export COLORTERM="${COLORTERM:-truecolor}"

export PATH="$HOME/.cargo/bin:$PATH"
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=~/.npm-global/bin:$PATH

# -- for claude code via open router
# load file
if [ -f "$HOME/.claude_api" ]; then
    source "$HOME/.claude_api"
fi

# --- history -----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

# --- completion --------------------------------------------------------------
autoload -Uz compinit && compinit -u 2>/dev/null || true

# --- prompt ------------------------------------------------------------------
eval "$(starship init zsh)"

# --- tools -------------------------------------------------------------------
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# --- plugins -----------------------------------------------------------------
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- prompt mark (foot terminal) ---------------------------------------------
precmd() { [[ -t 1 ]] && printf '\e]133;A\e\\' ; }

# --- aliases -----------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first -1'
  alias l='eza --icons --group-directories-first -1'
  alias ll='eza -l --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
  alias lla='eza -la --icons --group-directories-first'
else
  alias ls='ls --color=auto'
  alias l='ls -1'
  alias ll='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
fi

alias lg='lazygit'

nvim() {
    neovide --no-fork "$@" >/dev/null 2>&1
}

# --- abbreviation expander ---------------------------------------------------
typeset -gA ABBRS

expand-or-insert-space() {
  local word="${LBUFFER##* }"
  if [[ -n "${ABBRS[$word]}" ]]; then
    LBUFFER="${LBUFFER%$word}${ABBRS[$word]} "
    zle reset-prompt
  else
    zle .self-insert
  fi
}
zle -N expand-or-insert-space
bindkey ' ' expand-or-insert-space

# --- options -----------------------------------------------------------------
setopt CORRECT EXTENDED_GLOB

# --- extras ------------------------------------------------------------------
[ -f "${HOME}/.local/state/caelestia/sequences.txt" ] && \
  cat "${HOME}/.local/state/caelestia/sequences.txt" 2>/dev/null

[ -f "$HOME/dotfiles/zsh/.zshrc.local" ] && \
  source "$HOME/dotfiles/zsh/.zshrc.local"

[[ -f /home/xero/.dart-cli-completion/zsh-config.zsh ]] && \
  source /home/xero/.dart-cli-completion/zsh-config.zsh

# --- greeter -----------------------------------------------------------------
fastfetch
export PATH="/home/xero/.cmake-deps/cmake/linux/x64/bin:$PATH" # Added by JetBrains IDE

# bun completions
[ -s "/home/xero/.bun/_bun" ] && source "/home/xero/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

. "$HOME/.local/share/../bin/env"
