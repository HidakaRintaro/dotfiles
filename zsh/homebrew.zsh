# homebrewでインストールしたパッケージのpathを通す設定

# coreutils (GNUのやつ)
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# make (gmake)
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# sed (gsed)
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# curl (gcurl) 
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# grep (ggrep)
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
