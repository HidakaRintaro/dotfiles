#!/bin/zsh

set -ue

echo ''
echo '## brewのセットアップ中...'
echo ''

ln -fsv $DOTFILES/brew/.Brewfile $HOME/.Brewfile

echo ''
echo '## brewのセットアップが完了しました!'
echo ''