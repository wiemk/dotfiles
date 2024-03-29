# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
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
alias sl='ls'

alias cp='command cp -av'
alias ln='command ln -vi'
alias mkdir='command mkdir -v'
alias mv='command mv -v'
alias rm='command rm -vI'

alias dnf='sudo dnf'
alias dnfw='sudo dnf --setopt=install_weak_deps=False'
alias dust='dust -rx'
alias grep='grep --color=auto'
alias kc='koji-check'
alias kdl='koji-arch'
alias mm='neomutt'
alias mutt='neomutt'
alias pe='command up'
alias srun='sc-run-bg'
alias tma='tm'
alias top='htop'
alias unsha='socat -t 5 - tcp:unsha.re:10000'
alias ydl='yt-dlp'
alias mpvr="command mpv --input-ipc-server=\${XDG_RUNTIME_DIR}/mpv.sock"

if has batman; then
	alias man='batman'
fi
