#!/bin/zsh

# Error Check
set -ue

echo ''
echo '## Starshipのセットアップ中...'
echo ''

if [[ ! -d $HOME/.starship ]]; then
  echo '# .starship フォルダを作成中...'

  mkdir -p $HOME/.starship
fi

ln -fsv $DOTFILES/starship/starship.toml $HOME/.starship/starship.toml


echo ''
echo '## Starshipのセットアップが完了しました!'
echo ''