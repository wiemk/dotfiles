# vi: set ft=sh ts=4 sw=0 sts=-1 sr noet nosi tw=80 fdm=manual:
# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091

# non-interactive, return early
[[ -z $PS1 ]] && return

# DEBUG
if [[ -e ${XDG_CONFIG_HOME}/bash/_debug ]]; then
	init_debug() {
		local -r script=$(readlink -e -- "${BASH_SOURCE[1]}") ||
			return
		printf '%d%s\n' "${EPOCHSECONDS}" ": ${script}" \
			>>"${XDG_RUNTIME_DIR:-/run/user/${UID}}/profile_dbg.log"
	}
else
	init_debug() { :; }
fi

init_debug

export RCDIR=${XDG_CONFIG_HOME:-~/.config/}/bash

if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
elif [[ -f /etc/bash.bashrc ]]; then
	source /etc/bash.bashrc
fi

umask 022

#set -o physical
set +o histexpand

{
	shopt -s histappend \
		histreedit \
		cmdhist \
		extglob \
		globstar \
		dotglob \
		lastpipe \
		autocd \
		direxpand \
		checkwinsize \
		cdspell \
		assoc_expand_once \
		checkhash \
		lithist \
		no_empty_cmd_completion
} 2>/dev/null

if [[ -f $RCDIR/rc.pre ]]; then
	source "${RCDIR}/rc.pre"
fi

BSTATE=${XDG_STATE_HOME:-${HOME}/.local/state}/bash

HISTCONTROL=ignoreboth
HISTIGNORE='history*:'
HISTFILE=${BSTATE}/history
HISTSIZE=10000
HISTFILESIZE=50000

if ! [[ -d $BSTATE ]]; then
	mkdir -p "$BSTATE"
fi
unset BSTATE
history -a

has() {
	if hash "$1" &>/dev/null; then
		return 0
	fi
	return 1
}

has_all() {
	for cmd in "$@"; do
		if ! has "${cmd}"; then
			return 1
		fi
	done
}

msg() {
	echo >&2 -e "${1-}"
}

has_line_editing() {
	if [[ ${SHELLOPTS} =~ (vi|emacs) ]]; then
		return 0
	fi
	return 1
}

contains_assoc() {
	local array="$1[@]"
	local item=$2
	for e in "${!array}"; do
		[[ $e == "$item" ]] && return 0
	done
	return 1
}

contains() {
	local -n array=$1
	local item=$2
	for e in "${array[@]}"; do
		[[ $e == "$item" ]] && return 0
	done
	return 1
}

trim() {
	local var=$*
	var=${var#"${var%%[![:space:]]*}"}
	var=${var%"${var##*[![:space:]]}"}
	printf '%s' "$var"
}

if has systemd-detect-virt; then
	is_container() {
		local -r container=$(systemd-detect-virt --container)
		if [[ -n $container && $container != "none" ]]; then
			echo "$container"
			return 0
		fi
		return 1
	}

	container=$(is_container)
	if [[ -n $container ]]; then
		export CONTAINER=$container
	fi
fi

prompt() {
	msg_bar() {
		local text=$1
		local div_width=80
		printf "%${div_width}s\n" ' ' | tr ' ' -
		printf '%s\n' "$text"
	}
	local question=$1
	while true; do
		msg_bar "$question"
		read -p "[y]es or [n]o (default: no) : " -r answer
		case "$answer" in
		y | Y | yes | YES | Yes)
			return 0
			;;
		n | N | no | NO | No | *[[:blank:]]* | "")
			return 1
			;;
		*)
			msg_bar "Please answer [y]es or [n]o."
			;;
		esac
	done
}

# note: files beginning with `99-' are not version controlled
if [[ -d $RCDIR/source.d ]]; then
	shopt -s nullglob
	# Plugins are allowed to modify the environment via export
	# but are self-contained and loading order shall not matter.
	# Functions should be pure/side-effect free but may depend
	# on each other.
	for src in "$RCDIR"/source.d/*.sh; do
		source "$src"
	done
fi
shopt -u nullglob

if [[ -f $RCDIR/rc.post ]]; then
	source "${RCDIR}/rc.post"
fi