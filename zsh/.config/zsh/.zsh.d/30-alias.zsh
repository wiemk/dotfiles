# .zsh.d/20-alias.zsh

#########################################################################
# COREUTILS
#########################################################################
#
# file operations
alias rr='rm -rvI'
alias rm='rm -vI'
alias cp='cp -vi'
alias mv='mv -vi'
alias ln='ln -vi'
alias mkdir='mkdir -vp'
# permissions
alias sudo=ngsudo
alias chmod='chmod -c --preserve-root'
alias chown='chown -c --preserve-root'
alias chgrp='chgrp -c --preserve-root'
# navigation
alias ls='ls --color=auto --group-directories-first -AhXF'
alias ll='ls --color=auto --group-directories-first -AlhXF'
# information
alias netstat='lsof -Pnl +M -i4'
alias netstat6='lsof -Pnl +M -i6'
alias tmux='tmux -2'
alias dmesg='dmesg -exL'

#########################################################################
# UTILITY
#########################################################################
#
alias ix="curl -F 'f:1=<-' ix.io"
alias sprunge="curl -F 'sprunge=<-' sprunge.us"
alias xc='xclip -o | ix'
alias performance='perf top -g -p'
alias largest='du --max-depth=1 2> /dev/null | sort -n -r | head -n20'

#########################################################################
# XDG fixes
#########################################################################
#
alias ncmpcpp="ncmpcpp -c $XDG_CONFIG_HOME/ncmpcpp/config"
alias ncmpc="ncmpcpp -c $XDG_CONFIG_HOME/ncmpcpp/config"

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
