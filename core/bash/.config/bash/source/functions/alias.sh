# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash

on_debug

alias c='command'

alias l.='command ls -d .* --color=auto' 2>/dev/null
alias ll='command ls -l --color=auto' 2>/dev/null
alias ls='command ls --color=auto --show-control-chars --group-directories-first -AlhXF'

alias e='edit'
alias ve='visual'

alias cp='command cp -avi'
alias grep='grep --color=auto'
alias ln='command ln -vi'
alias mkdir='command mkdir -v'
alias mv='command mv -vi'
alias rm='command rm -vI'

alias chgrp='command chgrp -c --preserve-root'
alias chmod='command chmod -c --preserve-root'
alias chown='command chown -c --preserve-root'

alias unsh='ncat unsha.re 10000'
