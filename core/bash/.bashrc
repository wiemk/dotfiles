# vi:set ft=bash ts=4 sw=4 noet noai:

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bashrc' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

export BDOTDIR=${XDG_CONFIG_HOME:-~/.config/}/bash 

if [[ -f $BDOTDIR/bashrc.pre ]]; then
	source "${BDOTDIR}/bashrc.pre"
fi

if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

shopt -s histappend
shopt -s extglob
shopt -s lastpipe
shopt -s direxpand
shopt -s checkwinsize

# some useful settings
shopt -s dotglob
shopt -s autocd
shopt -s cdspell
shopt -s assoc_expand_once
shopt -s checkhash
shopt -s globstar
shopt -s lithist

BSTATE=${XDG_STATE_HOME:-~/.local/state}/bash

HISTCONTROL=ignoreboth
HISTIGNORE="history*:vim*:nvim*:cd *:ls *:"
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

pathmunge () {
	case ":${PATH}:" in
		*:"$1":*)
			;;
		*)
			if [ "$2" = "after" ] ; then
				PATH=$PATH:$1
			else
				PATH=$1:$PATH
			fi
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

# Redraw prompt line
__ehc()
{
	if [[ -n $1 ]]; then
		bind '"\er": redraw-current-line'
		bind '"\e^": magic-space'
		READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
		READLINE_LINE=$(trim "$READLINE_LINE")
		READLINE_POINT=$((READLINE_POINT + ${#1}))
	else
		bind '"\er":'
		bind '"\e^":'
	fi
}

if [[ -f /run/.containerenv ]] || systemd-detect-virt --quiet --container; then
	export CONTAINER=1
fi
shopt -s nullglob
# plugins are allowed to modify the environment via export
pd="${BDOTDIR}/plugins"
if [[ -d $pd ]]; then
	for p in "$pd"/*; do
		source "$p"
	done
fi
unset pd

# functions should be pure
fd="${BDOTDIR}/functions"
if [[ -d $fd ]]; then
	for f in "$fd"/*; do
		source "$f"
	done
fi
unset fd
shopt -u nullglob

if [[ -f $BDOTDIR/bashrc.post ]]; then
	source "${BDOTDIR}/bashrc.post"
fi
