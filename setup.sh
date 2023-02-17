#!/bin/bash

echo '==============================================================================================='
echo '            ___                                ______     ___      ____                        '
echo '           /  /|                 ___          /  ___/    /__/|    /  _/|                       '
echo '          /  / /  ________   ___/  /___   ___/  /___     |__|/   /  /|_/    ___         ______ '
echo '    _____/  / /  /  __   /| /___   ___/| /___   ___/|  ____     /  / /   /  _   \     /  ____/|'
echo '   /  __   / /  /  /|/  / / |__/  /|__|/ |__/  /|__|/ /  _/|   /  / /  /  /|_/  /|   /  /|_ _|/'
echo '  /  /|/  / /  /  / /  / /    /  / /       /  / /    /  /|_/  /  / /  /  ______/ /  |\___  \   '
echo ' /  /_/  / /  /  /_/  / /    /  /_/      _/  / /   _/  / /  _/  / /  /  /______|/  __\__/  /|  '
echo '/_______/ /  /_______/ /    /_____/|    /___/ /   /___/ /  /___/ /   |\________/| /______ / /  '
echo '|_______|/   |_______|/     |______/    |____/    |____/   |___|/    \_________|/ |______ |/   '
echo '                                                                                               '
echo '===================================================== https://github.com/hidakarintaro/dotfiles'

# dotfilesの
export DOTFILES="$HOME/dotfiles"

set -ue

echo ''

# Xcodeのインストール
# xcode-select --install

# homebrewのインストール
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ここにAppleにログインしたか確認のメッセを出す

info () {
  printf "\r[\033[00;34mINFO\033[0m] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

link_file () {
  local src=$1 dst=$2

  local overwrite=
  local backup=
  local skip=
  local action=

  if [[ -f $dst || -d $dst ||  -L $dst ]]
  then

    if [[ $overwrite_all == "false" && $backup_all == "false" && $skip_all == "false" ]]
    then

      local currentSrc="$(readlink $dst)"

      if [[ $currentSrc == $src ]]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action  < /dev/tty

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [[ $overwrite == "true" ]]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [[ $backup == "true" ]]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [[ $skip == "true" ]]
    then
      success "skipped $src"
    fi
  fi

  if [[ $skip != "true" ]]  # "false" or empty
  then
    ln -fsv "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  find -H "$DOTFILES" -maxdepth 2 -name 'links.prop' -not -path '*.git*' | while read linkfile
  do
    cat "$linkfile" | while read line
    do
        local src dst dir
        src=$(eval echo "$line" | cut -d '=' -f 1)
        dst=$(eval echo "$line" | cut -d '=' -f 2)
        dir=$(dirname $dst)

        mkdir -p "$dir"
        link_file "$src" "$dst"
    done
  done
}

install_dotfiles

echo ''
echo ''
success 'All installed!'