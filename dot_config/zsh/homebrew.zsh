# homebrewでインストールしたパッケージのpathを通す設定

# Homebrew本体を初期化する。
# brew shellenvがHOMEBREW_PREFIX等を設定するので、以降のパスをアーキ非依存に書ける。
# Apple Silicon(/opt/homebrew)を優先し、Intel(/usr/local)にもフォールバックする。
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# coreutils (GNUのやつ)
export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

# make (gmake)
export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"

# sed (gsed)
export PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"

# curl (gcurl)
export PATH="$HOMEBREW_PREFIX/opt/curl/bin:$PATH"

# grep (ggrep)
export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"

# PHPに必要なライブラリ群
export PATH="$HOMEBREW_PREFIX/opt/bison/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/libxml2/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/jpeg/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/bzip2/bin:$PATH"
