# ==========================================================
#  ZSH GREETER (kitty image + fastfetch)
#  Split-safe, starship-safe, fastfetch-version-safe
# ==========================================================
[[ -o interactive ]] || return

# ----------------------------------------------------------
# State
# ----------------------------------------------------------
typeset -g __GREETER_SHOWN=0

# ----------------------------------------------------------
# Greeter
# ----------------------------------------------------------
zsh_greeting() {
  # Clear screen safely
  tput clear
  tput cup 0 0
  
  cols=$(tput cols)
  
  # ---- layout constants ----
  top_y=1
  img_x=2
  img_y=$top_y
  gap=4
  
  # Your fastfetch config produces a box that's 41 chars wide
  # (╭───...───╮ is 39 chars + content fits in ~37 chars)
  ff_width=41
  
  # ---- image breakpoints ----
  img_w=32
  img_h=24
  
  # Minimum width needed: image + gap + fastfetch
  min_width=$(( img_w + gap + ff_width ))
  
  if (( cols < min_width )); then
    img_w=24
    img_h=18
    min_width=$(( img_w + gap + ff_width ))
  fi
  
  # ---- if still too small, fallback to fastfetch only ----
  if (( cols < min_width )); then
    fastfetch
    return
  fi
  
  # ---- compute padding for fastfetch ----
  # Center the layout or use left padding
  total_width=$(( img_w + gap + ff_width ))
  
  if (( cols >= total_width )); then
    # We have enough space, position fastfetch after image + gap
    ff_margin=$(( img_x + img_w + gap ))
  else
    # Shouldn't reach here due to fallback, but safety check
    ff_margin=$(( cols - ff_width - 1 ))
  fi
  
  # Ensure margin is reasonable
  (( ff_margin < 0 )) && ff_margin=0
  
  pad=$(printf '%*s' "$ff_margin")
  
  # ---- draw kitty image ----
  if [[ "$TERM" == "xterm-kitty" ]]; then
    kitty +kitten icat --silent \
      --place=${img_w}x${img_h}@${img_x}x${img_y} \
      ~/dotfiles/zsh/logo.png 2>/dev/null
  fi
  
  # ---- draw fastfetch ----
  # Position cursor at top for fastfetch output
  tput cup $(( top_y > 0 ? top_y - 1 : 0 )) 0
  
  # Run fastfetch and pad each line
  fastfetch 2>/dev/null | awk -v pad="$pad" '{ print pad $0 }'
}

# ----------------------------------------------------------
# Hook (does NOT override existing precmd)
# ----------------------------------------------------------
__greeter_precmd() {
  if (( __GREETER_SHOWN == 0 )); then
    zsh_greeting
    __GREETER_SHOWN=1
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __greeter_precmd
