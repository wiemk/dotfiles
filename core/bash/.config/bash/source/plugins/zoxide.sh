# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash

on_debug

if ! has zoxide; then
	return
fi

export _ZO_EXCLUDE_DIRS='/media/*:/mnt/*:/tmp/*'

eval "$(zoxide init bash)"
if has fzf; then
	bind -m emacs '"\C-xx": "\C-x2\e^\er"'
	bind -m emacs '"\C-g": "\C-x2\e^\er"'
	bind -m emacs -x '"\C-x2": zi'
fi
