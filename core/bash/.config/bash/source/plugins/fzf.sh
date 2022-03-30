# vi:set ft=bash ts=4 sw=4 noet noai:
# shellcheck disable=2155,1090

on_debug

if ! has fzf; then
	return
fi

FZF_DEFAULT_OPTS=${FZF_DEFAULT_OPTS:-"--height=50% --info=inline"}

# https://github.com/junegunn/fzf/wiki/examples#command-history
bind '"\C-r": "\C-x1\e^\er"'
bind -x '"\C-x1": __fzf_history'

# Redraw prompt line
__ehc() {
	if [[ -n $1 ]]; then
		bind -m emacs '"\er": redraw-current-line'
		bind -m emacs '"\e^": magic-space'
		READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
		READLINE_LINE=$(trim "$READLINE_LINE")
		READLINE_POINT=$((READLINE_POINT + ${#1}))
	else
		bind -m emacs '"\er":'
		bind -m emacs '"\e^":'
	fi
}

__fzf_history() {
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
		echo "$pid" | xargs kill -"${1:-15}"
	fi
}

_fzfyank() {
	local cmd=$1
	if [[ $cmd != "fd "* ]]; then
		local cmd="$cmd | xargs -0 ls -dh --color=always"
	fi
	local pre=${READLINE_LINE:0:READLINE_POINT}
	local suf=${READLINE_LINE:READLINE_POINT}
	local qry=${pre##*[ /=]}
	local str=$(FZF_DEFAULT_COMMAND=$cmd fzf -q "$qry" --reverse --ansi \
		--preview='ls -ldh --color=always {}' \
		--preview-window=down,1,border-none)
	if [[ $str ]]; then
		pre=${pre%"$qry"}
		str=${str@Q}" "
		READLINE_LINE=${pre}${str}${suf}
		READLINE_POINT=$((READLINE_POINT - ${#qry} + ${#str}))
	fi
}

# Alt+[df] - local dir/all selection
if has fd; then
	bind -m emacs -x '"\ed": _fzfyank "fd --color=always --exact-depth=1 --type=d"'
	bind -m emacs -x '"\ef": _fzfyank "fd --color=always --exact-depth=1"'
	# Alt+Shift+[DF] - recursive dir/all selection
	bind -m emacs -x '"\eD": _fzfyank "fd --color=always --type=d"'
	bind -m emacs -x '"\eF": _fzfyank "fd --color=always"'
else
	bind -m emacs -x '"\ed": _fzfyank "find . -xdev -maxdepth 1 -name .\?\* -prune -o -xtype d -printf %P\\\0"'
	bind -m emacs -x '"\ef": _fzfyank "find . -xdev -maxdepth 1 -name .\?\* -prune -o -printf %P\\\0"'
	bind -m emacs -x '"\eD": _fzfyank "find . -xdev -mindepth 1 -name .\?\* -prune -o -xtype d -printf %P\\\0"'
	bind -m emacs -x '"\eF": _fzfyank "find . -xdev -mindepth 1 -name .\?\* -prune -o -printf %P\\\0"'
fi
