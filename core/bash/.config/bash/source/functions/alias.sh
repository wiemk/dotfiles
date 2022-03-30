# vi:set ft=bash ts=4 sw=4 noet noai:

on_debug

alias ll='command ls -l --color=auto' 2>/dev/null
alias l.='command ls -d .* --color=auto' 2>/dev/null
alias ls='command ls --color=auto --show-control-chars --group-directories-first -AlhXF'

alias rm='command rm -vI'
alias cp='command cp -avi'
alias mv='command mv -vi'
alias ln='command ln -vi'
alias mkdir='command mkdir -v'
alias grep='grep --color=auto'

alias chmod='command chmod -c --preserve-root'
alias chown='command chown -c --preserve-root'
alias chgrp='command chgrp -c --preserve-root'

alias v="\${EDITOR:-vi}"
alias vi="\${EDITOR:-vi}"
alias e="\${EDITOR:-editor}"
alias c='command'
