source_if_exists () {
  if [[ -f "$1" ]]; then
    source "$1"
  fi
}

source_if_exists $HOME/dotfiles/zsh/homebrew.zsh
source_if_exists $HOME/dotfiles/zsh/aliases.zsh
source_if_exists $HOME/dotfiles/zsh/starship.zsh

# Load Starship
eval "$(starship init zsh)"

autoload -Uz compinit && compinit  # 補完機能を有効にする
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 小文字でも大文字ディレクトリ、ファイルを補完できるようにする

# Claude
export PATH="$HOME/.claude/local:$PATH"

# pnpmの使用を許可
export VOLTA_FEATURE_PNPM=1
