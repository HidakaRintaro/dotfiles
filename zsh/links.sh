#!/bin/zsh

set -ue

echo ''
echo '## zshのセットアップ中...'
echo ''

ln -fsv $DOTFILES/zsh/env.zsh $HOME/.zshenv
ln -fsv $DOTFILES/zsh/rc.zsh $HOME/.zshrc

echo ''
echo '## zshのセットアップが完了しました!'
echo ''