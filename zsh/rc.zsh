source_if_exists () {
  if [[ -f "$1" ]]; then
    source "$1"
  fi
}

source_if_exists $HOME/dotfiles/zsh/aliases.zsh
source_if_exists $HOME/dotfiles/zsh/starship.zsh


autoload -Uz compinit && compinit  # 補完機能を有効にする
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 小文字でも大文字ディレクトリ、ファイルを補完できるようにする

# Added by Docker Desktop
source /Users/hidakarintaro/.docker/init-zsh.sh || true 

# Load Starship
eval "$(starship init zsh)"
