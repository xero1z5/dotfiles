# only run for interactive shells
[[ $- != *i* ]] && return

source ~/.dotfiles/zsh/greeter.zsh

# --- environment -------------------------------------------------------------
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export LANG="${LANG:-en_US.UTF-8}"
export TERM="${TERM:-xterm-kitty}"
export COLORTERM="${COLORTERM:-truecolor}"

# --- history -----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

typeset -gA ABBRS

# --- completion ----------------------------------------------------------------
autoload -Uz compinit && compinit -u 2>/dev/null || true

# --- starship ------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- direnv & zoxide ----------------------------------------------------------
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# --- zsh-autosuggestions ------------------------------------------------------
# highlight style: fish used brblack for autosuggestions -> map to bright black
# (plugin expects style like 'fg=8' or 'fg=black,bold')
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'   # bright-black like fish's brblack

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -f "${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

# --- zsh-syntax-highlighting ---------------------------------------------------
# Map fish colour choices to zsh-syntax-highlighting styles where sensible.
# (You can tweak the right-hand values: 'fg=colour' or 'fg=color,bold' etc.)
# Example mapping based on your fish vars:
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=red'
ZSH_HIGHLIGHT_STYLES[command]='none'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[bracket]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[path]='fg=green'                # fish_color_cwd -> green
ZSH_HIGHLIGHT_STYLES[path_pathsep]='fg=red'          # fish_color_cwd_root -> red-ish
ZSH_HIGHLIGHT_STYLES[parameter]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[quote]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=cyan,bold'     # fish had bold for redirection
ZSH_HIGHLIGHT_STYLES[error]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[status]='fg=red'
ZSH_HIGHLIGHT_STYLES[user]='fg=10'                   # bright green (user color)
ZSH_HIGHLIGHT_STYLES[match]='fg=white,bg=8,bold'     # search-match style, fish used white on brblack

# now source the plugin (must be sourced after the style vars)
if [ -f "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# --- prompt mark for foot terminal (keeps behaviour used by your scripts) ------
precmd() { [[ -t 1 ]] && printf '\e]133;A\e\\' ; }

# --- aliases & ls replacement ---------------------------------------------------
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
alias nvim='neovide --no-fork'

# widget: expand last word if it's in ABBRS, otherwise insert the bound key (space)
expand-or-insert-space() {
  # get the word immediately left of the cursor
  local word="${LBUFFER##* }"
  # if LBUFFER has no spaces, word is full buffer; that's OK
  if [[ -n "${ABBRS[$word]}" ]]; then
    # replace the word with its expansion
    LBUFFER="${LBUFFER%$word}${ABBRS[$word]}"
    # insert a space after expansion
    LBUFFER="${LBUFFER} "
    zle reset-prompt
  else
    # default behavior: insert a space
    zle .self-insert
  fi
}
zle -N expand-or-insert-space expand-or-insert-space
# bind space to the widget (make sure this uses the space key)
bindkey ' ' expand-or-insert-space

# --- useful zsh options ---------------------------------------------------------
setopt CORRECT
setopt EXTENDED_GLOB

# --- optional: apply caelestia sequences if present ------------------------------
[ -f "${HOME}/.local/state/caelestia/sequences.txt" ] && cat "${HOME}/.local/state/caelestia/sequences.txt" 2>/dev/null

# --- machine specific overrides --------------------------------------------------
[ -f "$HOME/.dotfiles/zsh/.zshrc.local" ] && source "$HOME/.dotfiles/zsh/.zshrc.local"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/xero/.dart-cli-completion/zsh-config.zsh ]] && . /home/xero/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

