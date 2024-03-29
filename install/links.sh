#!/bin/bash

set -ue

echo ''

source $DOTFILES/install/print.sh

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

      if [[ $currentSrc == $src ]] # has the symbolic link changed?
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