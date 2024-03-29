# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

if ! has zoxide; then
	return
fi

export _ZO_EXCLUDE_DIRS='/media/*:/mnt/*:/tmp/*'

eval "$(zoxide init bash)"
if has fzf; then
	bind -m emacs '"\C-g": "\C-x2\e^\C-m"'
	bind -m emacs -x '"\C-x2": zi'

	bind -m vi-insert '"\C-g": "\C-x2\e^\C-m"'
	bind -m vi-insert -x '"\C-x2": zi'

	bind -m vi-command '"\C-g": "\C-x2\e^\C-m"'
	bind -m vi-command -x '"\C-x2": zi'
fi
