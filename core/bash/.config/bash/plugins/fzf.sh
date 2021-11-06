# vi:set ft=bash ts=4 sw=4 noet noai:

if ! has fzf; then
	return
fi

# https://github.com/junegunn/fzf/wiki/examples#command-history
bind '"\C-r": "\C-x1\e^\er"'
bind -x '"\C-x1": __fzf_history';

__fzf_history () {
	__ehc "$(history | fzf --tac --tiebreak=index | grep -oP '^\s*([0-9]+)\s+\K.*$')"
}

fkill() {
	local pid 
	if [[ "$UID" != "0" ]]; then
		pid=$(ps -f -u $UID --no-headers | fzf -m | awk '{print $2}')
	else
		pid=$(ps -ef --no-headers | fzf -m | awk '{print $2}')
	fi

	if [[ -n $pid ]]; then
		echo $pid | xargs kill -${1:-15}
	fi
}
