#!/usr/bin/false
# shellcheck shell=bash
# shellcheck disable=2155,1090

if hash &>/dev/null; then
	_has() {
		hash "$1" &>/dev/null
	}
else
	# hashing disabled (NixOS)
	_has() {
		command -v "$1" &>/dev/null
	}
fi

_has_oneof() {
	for cmd in "$@"; do
		if _has "${cmd}"; then
			return 0
		fi
	done
	return 1
}

_has_emit() {
	if ! _has "$1"; then
		msg "$1" 'not found in PATH'
		return 1
	fi
}

_has_all() {
	for cmd in "$@"; do
		if ! _has "${cmd}"; then
			return 1
		fi
	done
}

_has_all_emit() {
	for cmd in "$@"; do
		if ! _has_emit "${cmd}"; then
			return 1
		fi
	done
}

_msg() {
	printf '%b' "$*" '\n' >&2
}

_die() {
	local msg=$1
	local code=${2-1}
	_msg "$msg"
	exit "$code"
}

_prompt() {
	__msg() {
		local text=$1
		local div_width="120"
		printf "%${div_width}s\n" ' ' | tr ' ' -
		printf "%s\n" "$text"
	}
	local question=$1
	while true; do
		__msg "$question"
		read -p "[y]es or [n]o (default: no) : " -r answer
		case "$answer" in
			y | Y | yes | YES | Yes)
				return 0
				;;
			n | N | no | NO | No | *[[:blank:]]* | "")
				return 1
				;;
			*)
				__msg "Please answer [y]es or [n]o."
				;;
		esac
	done
}

_is_tmux_ps() {
	local -r tm=$(ps -p "$(ps -p $$ -o ppid= | xargs -n 1)" -o comm=)
	[[ $tm == tmux* ]]
}

_is_tmux() {
	[[ -v TMUX_PANE ]]
}

_tmux_rename_window() {
	local -r title=$1
	local -r cmd=$2
	shift 2

	if ! _is_tmux; then
		eval "command $cmd $*"
		return
	fi

	# no rename when splits exist
	local -ri panes="$(command tmux display-message -p '#{window_panes}')"
	if ((panes > 1)); then
		eval "command $cmd $*"
		return
	fi

	__tmux_pty_to_pane_id() {
		local -r tty=$1
		while read -r pane; do
			local pane_id=${pane#*:}
			local pane_tty=${pane%:*}
			if [[ $tty == "$pane_tty" ]]; then
				echo "$pane_id"
			fi
		done < <(command tmux list-panes -aF "#{pane_tty}:#{pane_id}")
	}

	local -r pane_id=$(__tmux_pty_to_pane_id "$(tty)")
	if [[ -z $pane_id ]]; then
		eval "command $cmd $*"
		return
	fi

	command tmux rename-window -t "$pane_id" "$title"
	command $cmd "$@"
	command tmux set-option -qwp -t "$pane_id" automatic-rename 'on'
}

# vi: set ft=sh ts=4 sw=0 sts=-1 sr noet nosi tw=80 fdm=manual:
