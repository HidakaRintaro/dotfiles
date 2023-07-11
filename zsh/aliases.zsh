# Alias
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias c='clear'
alias mkdir='mkdir -p'

alias sed='gsed'
alias make='gmake'

alias -g C='| pbcopy'

idea() {
    open -na "IntelliJ IDEA.app" --args nosplash "$@"
}