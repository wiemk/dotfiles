alias psign='fun_addandsign'
alias ownedby='fun_ownedby'
alias orphans='pacman -Qtdq'
alias update-dist='sudo pacman -Syu'
alias listaur='pacman -Qm'
alias checkinstalled='pacman -Qkk'
alias purgeall='purgeorphans'
alias purge='fun_purge'
alias purgeorphans='fun_purgeorphans'
alias showlocal='fun_showlocal'
alias showremote='fun_showremote'
alias listfiles='fun_listfiles'
alias adopt='fun_adopt'
alias abandon='fun_abandon'
alias modified='fun_checkmodified'
alias explicit='pacman -Qet'

alias update-repo='git checkout master && git pull && git checkout - && git rebase master'
alias list-services='sudo systemctl list-units --type=service'
alias sctl='systemctl'
alias ssctl='sudo systemctl'

alias rr='rm -rvI'
alias rm='rm -vI'
alias cp='cp -vi'
alias mv='mv -vi'
alias ln='ln -vi'
alias mkdir='mkdir -vp'
alias sude='sudo -E'

alias e="$EDITOR"
alias ae="$ALTERNATE_EDITOR"

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

alias performance='fun_performance'

