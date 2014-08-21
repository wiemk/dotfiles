alias psign='fun_addandsign'
alias ownedby='pacman -Qo'
alias orphans='pacman -Qtdq'
alias update-dist='sudo pacman -Syu'
alias listaur='pacman -Qm'
alias checkinstalled='pacman -Qkk'
alias purgeall='purgeorphans'
alias purge='sudo pacman -Rnsc'
alias purgeorphans='sudo pacman -Rnsc $(pacman -Qtdq)'
alias showlocal='pacman -Qi'
alias showremote='pacman -Si'
alias listfiles='pacman -Ql'
alias adopt='sudo pacman -D --asexplicit'
alias abandon='sudo pacman -D --asdeps'
alias modified='pacman -Qii'
alias explicit='pacman -Qet'

alias update-repo='git checkout master && git pull && git checkout - && git rebase master'
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

alias performance='perf top -g -p'
alias largest='du --max-depth=1 2> /dev/null | sort -n -r | head -n20'
