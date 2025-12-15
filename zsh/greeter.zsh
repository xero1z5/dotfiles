zsh_greeting() {
  clear

  cols=$(tput cols)
  rows=$(tput lines)

  img_w=32    # width in terminal cells you want the image to occupy
  img_h=24    # height in terminal cells
  img_x=3
  img_y=3

  # how many columns to push fastfetch right by (tweak +4 for spacing)
  ff_margin=$((img_w + 4))

  # create a pad string of ff_margin spaces
  pad=$(printf '%*s' "$ff_margin")

  if [[ "$TERM" == "xterm-kitty" ]]; then
    # place image at left. --silent avoids extra messages from kitty
    kitty +kitten icat --silent \
      --place=${img_w}x${img_h}@${img_x}x${img_y} \
      ~/.dotfiles/zsh/logo.png
  fi

  # move cursor a little down so fastfetch output doesn't start at the very top
  tput cup 2 0

  if command -v fastfetch >/dev/null; then
    # prefix each line with the pad so fastfetch appears to the right of the image
    fastfetch | awk -v pad="$pad" '{ print pad $0 }'
  fi
}

zsh_greeting
