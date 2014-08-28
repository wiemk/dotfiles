# .zsh.d/20-alias.zsh
#########################################################################
# PACKAGE MANAGEMENT
#########################################################################
#
alias pm_ownedby='pm -Qo'
alias pm_orphans='pm -Qtd'
alias pm_listaur='pm -Qmq'
alias pm_checkinstalled='pm -Qkk'
alias pm_showlocal='pm -Qi'
alias pm_showremote='pm -Si'
alias pm_listfiles='pm -Ql'
alias pm_explicit='pm -Qet'
alias pm_listofficial='pm -Qn'
alias pm_reversedep='pactree -lrud1'
# privileged
alias pm_purge='+pm -Rnsc'
alias pm_adopt='+pm -D --asexplicit'
alias pm_abandon='+pm -D --asdeps'
alias pm_up='+pm -Syyu'
alias pm_purgeorphans='+pm -Rnsc $(pm -Qtdq)'

#########################################################################
# SYSTEMD
#########################################################################
#
alias s_ls='+s list-units --type=service'

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

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
