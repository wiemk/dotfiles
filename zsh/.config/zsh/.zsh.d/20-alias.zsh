# .zsh.d/20-alias.zsh
alias pm_ownedby='pacman -Qo'
alias pm_orphans='pacman -Qtdq'
alias pm_update-dist='sudo pacman -Syu'
alias pm_listaur='pacman -Qm'
alias pm_checkinstalled='pacman -Qkk'
alias pm_purgeall='purgeorphans'
alias pm_purge='sudo pacman -Rnsc'
alias pm_purgeorphans='sudo pacman -Rnsc $(pacman -Qtdq)'
alias pm_showlocal='pacman -Qi'
alias pm_showremote='pacman -Si'
alias pm_listfiles='pacman -Ql'
alias pm_adopt='sudo pacman -D --asexplicit'
alias pm_abandon='sudo pacman -D --asdeps'
alias pm_explicit='pacman -Qet'

alias git_update-repo='git checkout master && git pull && git checkout - && git rebase master'
alias list-services='sudo systemctl list-units --type=service'
alias sctlu='systemctl --user'
alias sctl='sudo systemctl'

alias rr='rm -rvI'
alias rm='rm -vI'
alias cp='cp -vi'
alias mv='mv -vi'
alias ln='ln -vi'
alias mkdir='mkdir -vp'
alias sude='sudo -E'

alias chmod='chmod -c --preserve-root'
alias chown='chown -c --preserve-root'
alias chgrp='chgrp -c --preserve-root'

alias ls='ls --color=auto --group-directories-first -AhXF'
alias ll='ls --color=auto --group-directories-first -AlhXF'

alias netstat='lsof -Pnl +M -i4'
alias netstat6='lsof -Pnl +M -i6'
alias tmux='tmux -2'
alias dmesg='dmesg -exL'
alias ix="curl -F 'f:1=<-' ix.io"
alias sprunge="curl -F 'sprunge=<-' sprunge.us"
alias xc='xclip -o | ix'

alias performance='perf top -g -p'
alias largest='du --max-depth=1 2> /dev/null | sort -n -r | head -n20'
#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
