#!/bin/bash

# tmux config
if [ -z "$TMUX" ]; then
    if tmux has-session -t fedora 2>/dev/null; then
        tmux attach -t fedora
    else
        tmux new-session -s fedora
    fi
fi


# Fedora colors
FEDORA_BLUE="\[\033[38;5;27m\]"  # Fedora blue
FEDORA_NAVY="\[\033[38;5;33m\]" # Medium blue
FEDORA_LIGHT="\[\033[38;5;75m\]" # Light blue
WHITE="\[\033[38;5;255m\]"       # Bright white
RESET="\[\033[0m\]"              # Reset to default color

# Fedora-themed prompt
PS1="${FEDORA_NAVY}\t ${FEDORA_BLUE}\u@\h ${FEDORA_LIGHT}\w${WHITE}\$(git_branch)${RESET}$ "


# Git branch in prompt
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Enhanced cd command
cd() {
    builtin cd "$@" && ls -F
}

# Make a directory and change into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Bash completion setup
if [ -f /etc/bash_completion.d/ ]; then
    . /etc/bash_completion.d/*
fi

# Aliases
alias docker="podman"
alias neovim="vim"
alias nvim="vim"
alias vi="vim"
alias nano="vim"
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias mkdir="mkdir -p"
alias df="df -h"
alias du="du -h"
alias free="free -m"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"
alias c="clear"
alias reload-bash="source /etc/bashrc"
alias reload-tmux='tmux source-file /etc/tmux.conf'


# Set vim as default editor
export VISUAL=vim
export EDITOR="$VISUAL"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

# GNOME user directories
export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/usr/local/share:/usr/share:/usr/share/gnome"