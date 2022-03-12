# vi:set ft=bash ts=4 sw=4 noet noai:
# shellcheck disable=SC1090,SC1091

# non-interactive, return early
[[ -z "$PS1" ]] && return

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/bash/_debug" ]]; then
	on_debug() {
		local -r script=$(readlink -e -- "${BASH_SOURCE[1]}") ||
			return
		printf '%d%s\n' "${EPOCHSECONDS}" ": ${script}" \
			>>"${XDG_RUNTIME_DIR:-/run/user/${UID}}/profile_dbg.log"
	}
else
	on_debug() { :; }
fi

on_debug

export BDOTDIR=${XDG_CONFIG_HOME:-~/.config/}/bash

if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

#set -o physical
set +o histexpand

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

if [[ -f $BDOTDIR/rc.pre ]]; then
	source "${BDOTDIR}/rc.pre"
fi

BSTATE=${XDG_STATE_HOME:-~/.local/state}/bash

HISTCONTROL=ignoreboth
HISTIGNORE="history*:"
HISTFILE=${BSTATE}/history
HISTSIZE=10000
HISTFILESIZE=50000

if ! [[ -d $BSTATE ]]; then
	mkdir -p "$BSTATE"
fi
unset BSTATE
history -a

has() {
	if hash "${1}" &>/dev/null; then
		return 0
	fi
	return 1
}

has_line_editing() {
	if [[ ${SHELLOPTS} =~ (vi|emacs) ]]; then
		return 0
	fi
	return 1
}

pathmunge() {
	case ":${PATH}:" in
	*:"$1":*) ;;

	*)
		if [ "$2" = "after" ]; then
			PATH=$PATH:$1
		else
			PATH=$1:$PATH
		fi
		;;
	esac
}

contains_assoc() {
	local haystack="$1[@]"
	local needle=$2
	for e in "${!haystack}"; do
		[[ $e == "$needle" ]] && return 0
	done
	return 1
}

contains() {
	local -n haystack=$1
	local needle=$2
	for e in "${haystack[@]}"; do
		[[ $e == "$needle" ]] && return 0
	done
	return 1
}

trim() {
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"
	var="${var%"${var##*[![:space:]]}"}"
	printf '%s' "$var"
}

if [[ -f /run/.containerenv ]] ||
	systemd-detect-virt --quiet --container &>/dev/null; then
	export CONTAINER=1
fi

# note: files beginning with `99-' are not version controlled
if [[ -d $BDOTDIR/source.d ]]; then
	shopt -s nullglob
	# Plugins are allowed to modify the environment via export
	# but are self-contained and loading order shall not matter.
	# Functions should be pure/side-effect free but may depend
	# on each other.
	for src in "$BDOTDIR"/source.d/*.sh; do
		source "$src"
	done
fi
shopt -u nullglob

if [[ -f $BDOTDIR/rc.post ]]; then
	source "${BDOTDIR}/rc.post"
fi
