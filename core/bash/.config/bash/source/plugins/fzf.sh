# vi: set ft=sh ts=4 sw=4 sts=-1 sr et si tw=0 fdm=manual:
# shellcheck shell=bash
# shellcheck disable=2155,1090

init_debug

if ! has fzf; then
	return
fi

export FZF_DEFAULT_OPTS=${FZF_DEFAULT_OPTS:-"--height=50% --color fg:-1,bg:-1,hl:5,fg+:2,bg+:-1,hl+:5,info:42,prompt:-1,spinner:42,pointer:51,marker:33"}

bind -m emacs '"\C-r": "\C-x1\e^\er"'
bind -m emacs -x '"\C-x1": __fzf_history'

bind -m vi-command '"\C-r": "\C-x1\e^\er"'
bind -m vi-command -x '"\C-x1": __fzf_history'

bind -m vi-insert '"\C-r": "\C-x1\e^\er"'
bind -m vi-insert -x '"\C-x1": __fzf_history'

# Redraw prompt line
__ehc() {
	if [[ -n $1 ]]; then
		bind -m emacs '"\er": redraw-current-line'
		bind -m emacs '"\e^": magic-space'

		bind -m vi-command '"\er": redraw-current-line'
		bind -m vi-command '"\e^": magic-space'

		bind -m vi-insert '"\er": redraw-current-line'
		bind -m vi-insert '"\e^": magic-space'

		READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
		READLINE_LINE=$(trim "$READLINE_LINE")
		READLINE_POINT=$((READLINE_POINT + ${#1}))
	else
		bind -m emacs '"\er":'
		bind -m emacs '"\e^":'

		bind -m vi-command '"\er":'
		bind -m vi-command '"\e^":'

		bind -m vi-insert '"\er":'
		bind -m vi-insert '"\e^":'
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
	bind -m emacs -x '"\ef": _fzfyank "fd --hidden --unrestricted --exclude=.git/ --color=always"'
	bind -m emacs -x '"\ed": _fzfyank "fd --hidden --unrestricted --exclude=.git/ --color=always --type=d"'

	bind -m vi-command -x '"\ef": _fzfyank "fd --hidden --unrestricted --exclude=.git/ --color=always"'
	bind -m vi-command -x '"\ed": _fzfyank "fd --hidden --unrestricted --exclude=.git/ --color=always --type=d"'
else
	bind -m emacs -x '"\ef": _fzfyank "find . -xdev -name .\?\* -prune -o -printf %P\\\0"'
	bind -m emacs -x '"\ed": _fzfyank "find . -xdev -name .\?\* -prune -o -xtype d -printf %P\\\0"'

	bind -m vi-command -x '"\ef": _fzfyank "find . -xdev -name .\?\* -prune -o -printf %P\\\0"'
	bind -m vi-command -x '"\ed": _fzfyank "find . -xdev -name .\?\* -prune -o -xtype d -printf %P\\\0"'
fi