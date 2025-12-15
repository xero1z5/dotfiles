# greeter.zsh
[[ -o interactive ]] || return

typeset -g __GREETER_SHOWN=0

zsh_greeting() {
  tput clear
  tput cup 0 0

  cols=$(tput cols)

  top_y=1
  img_x=2
  img_y=$top_y
  gap=4
  ff_width=42

  img_w=32
  img_h=24

  if (( cols < img_w + gap + ff_width )); then
    img_w=24
    img_h=18
  fi

  if (( cols < img_w + gap + ff_width )); then
    fastfetch
    return
  fi

  ff_margin=$(( img_x + img_w + gap ))
  pad=$(printf '%*s' "$ff_margin")

  if [[ "$TERM" == "xterm-kitty" ]]; then
    kitty +kitten icat --silent \
      --place=${img_w}x${img_h}@${img_x}x${img_y} \
      ~/.dotfiles/zsh/logo.png
  fi

  tput cup $(( top_y > 0 ? top_y - 1 : 0 )) 0
  fastfetch | awk -v pad="$pad" '{ print pad $0 }'
}

__greeter_precmd() {
  if (( __GREETER_SHOWN == 0 )); then
    zsh_greeting
    __GREETER_SHOWN=1
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __greeter_precmd
