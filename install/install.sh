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
echo '===================================================== https://github.com/HidakaRintaro/dotfiles'

export DOTFILES="$HOME/dotfiles"

# I don't know how to load it when I run it in curl
# source ./install/print.sh

has() {
    type "$1" > /dev/null 2>&1
}

cd $HOME
if [[ ! -d $DOTFILES ]]; then
    if has "git"; then
        printf "\r[\033[00;34mINFO\033[0m] Downloading using git\n"
        git clone https://github.com/HidakaRintaro/dotfiles.git $DOTFILES

        # change access method to ssh
        cd $DOTFILES
        git remote set-url origin git@github.com:HidakaRintaro/dotfiles.git
    elif has "curl" || has "wget"; then
        TARBALL="https://github.com/HidakaRintaro/dotfiles/archive/refs/heads/main.tar.gz"
        if has "curl"; then
            printf "\r[\033[00;34mINFO\033[0m] Downloading using curl\n"
            curl -L ${TARBALL} -o main.tar.gz
        else
            printf "\r[\033[00;34mINFO\033[0m] Downloading using wget\n"
            wget ${TARBALL}
        fi
        tar -zxvf main.tar.gz
        rm -f main.tar.gz
        mv -f dotfiles-main "$DOTFILES/dotfiles"
    else
        printf "\r\033[2K  [\033[0;31mFAIL\033[0m] curl or wget or git required\n"
        echo ''
        exit
    fi

    source $DOTFILES/install/print.sh
    success "dotfiles downloaded!"

    cd $DOTFILES
    ./install/links.sh
else
    printf "\r\033[2K  [\033[0;31mFAIL\033[0m] dotfiles already exists\n"
    echo ''
    exit
fi

# Xcodeのインストール
# xcode-select --install

# homebrewのインストール
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ここにAppleにログインしたか確認のメッセを出す