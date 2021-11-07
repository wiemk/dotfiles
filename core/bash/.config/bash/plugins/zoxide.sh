# vi:set ft=bash ts=4 sw=4 noet noai:
on_debug

if ! has zoxide; then
	return
fi

eval "$(zoxide init bash)"
if has fzf; then
	bind '"\C-xx": "\C-x2\e^\er"'
	bind '"\C-g": "\C-x2\e^\er"'
	bind -x '"\C-x2": zi';
fi
