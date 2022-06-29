# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash

init_debug

alias c='command'
alias '+=''sudo'

alias chgrp='command chgrp -c --preserve-root'
alias chmod='command chmod -c --preserve-root'
alias chown='command chown -c --preserve-root'

alias info='info --vi-keys'

alias l.='command ls -d .* --color=auto' 2>/dev/null
alias ll='command ls -l --color=auto' 2>/dev/null
alias ls='command ls --color=auto --show-control-chars --group-directories-first -AlhXF'

alias cp='command cp -avi'
alias ln='command ln -vi'
alias mkdir='command mkdir -v'
alias mv='command mv -vi'
alias rm='command rm -vI'

alias dust='dust -rx'
alias grep='grep --color=auto'
alias kc='koji-check'
alias kdl='koji-arch'
alias mm='neomutt'
alias mutt='neomutt'
alias srun='sc-run'
alias tma='tm'
alias top='htop'
alias unsha='socat -t 5 - tcp:unsha.re:10000'
alias ydl='yt-dlp'
