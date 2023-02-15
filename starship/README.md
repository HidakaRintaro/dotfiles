# Starship
Starshipがどのような構成になっているのかを記録するためのもので、dotfilesのセットアップで下記の内容は自動でセットアップされます。  
そのため下記の内容を手動でセットアップする必要はありません。

## 公式
https://starship.rs/

## シンボリックリンク
```bash
ln -fsv $HOME/dotfiles/starship/starship.toml $HOME/.starship/starship.toml
```

## 環境変数
Docs: https://starship.rs/ja-JP/config/#config-file-location
```bash
# ~/.zshenv
export STARSHIP_CONFIG="$HOME/.starship/starship.toml"
export STARSHIP_CACHE="$HOME/.starship/cache"
```

## Font
Docs: https://www.nerdfonts.com/font-downloads
```bash
brew tap homebrew/cask-fonts &&
brew install --cask font-hack-nerd-font
```
VS CodeやWarpのフォントを`Hack Nerd Font`に設定。  
Warpは「View all available system fonts」にチェックを入れないとこのフォントは選択できません。  
それ以外のフォントにする際はアイコンが文字化けしないものを選択してください。

## 参考
> YouTube: https://youtu.be/NfggT5enF4o  
> Starship dotfiles: https://github.com/christianlempa/dotfiles  
> プリセット: https://starship.rs/ja-jp/presets/nerd-font.html