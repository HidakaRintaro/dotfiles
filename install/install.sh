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

export DOTFILES="$HOME/dotfiles"

./links.sh


# Xcodeのインストール
# xcode-select --install

# homebrewのインストール
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ここにAppleにログインしたか確認のメッセを出す

has() {
    type "$1" > /dev/null 2>&1
}

if [[ ! -d $DOTFILES ]]; then
    if has "git"; then
        git clone https://github.com/HidakaRintaro/dotfiles.git $DOTFILES
    elif has "curl" || has "wget"; then
        TARBALL="https://github.com/HidakaRintaro/dotfiles/archive/refs/heads/main.tar.gz"
        if has "curl"; then
            curl -L ${TARBALL} -o main.tar.gz
        else
            wget ${TARBALL}
        fi
        tar -zxvf main.tar.gz
        rm -f main.tar.gz
        mv -f dotfiles-main "$DOTFILES/dotfiles"
    else
        echo "curl or wget or git required"
        exit 1
    fi

    cd ${DOT_DIR}
    for f in *;
    do
        [[ "$f" == ".git" ]] && continue
        [[ "$f" == ".gitignore" ]] && continue
        [[ "$f" == ".DS_Store" ]] && continue
        [[ "$f" == "README.md" ]] && continue
        [[ "$f" == "install.sh" ]] && continue

        ln -snf $DOT_DIR/"$f" $HOME/".$f"
        echo "Installed .$f"
    done
else
    echo "dotfiles already exists"
    exit 1
fi