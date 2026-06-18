# homebrewでインストールしたパッケージのpathを通す設定

prepend_path_if_exists () {
  if [[ -d "$1" ]]; then
    export PATH="$1:$PATH"
  fi
}

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="$(brew --prefix)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -x /usr/local/bin/brew ]]; then
  HOMEBREW_PREFIX="/usr/local"
fi

if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  # coreutils (GNU)
  prepend_path_if_exists "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"

  # make (gmake)
  prepend_path_if_exists "$HOMEBREW_PREFIX/opt/make/libexec/gnubin"

  # sed (gsed)
  prepend_path_if_exists "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin"

  # curl (gcurl)
  prepend_path_if_exists "$HOMEBREW_PREFIX/opt/curl/bin"

  # grep (ggrep)
  prepend_path_if_exists "$HOMEBREW_PREFIX/opt/grep/libexec/gnubin"

  unset HOMEBREW_PREFIX
fi

unfunction prepend_path_if_exists
