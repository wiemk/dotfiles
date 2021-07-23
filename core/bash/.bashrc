# shellcheck shell=bash

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bashrc' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

# dircolors
if [[ -n $VIVID_LS_THEME ]] && hash vivid &>/dev/null; then
	# fedora uses this variable to detect custom LS_COLORS
	LS_COLORS="$(vivid generate "$VIVID_LS_THEME" 2>/dev/null)"
	if [[ -n $LS_COLORS ]]; then
		export LS_COLORS
		export USER_LS_COLORS=$VIVID_LS_THEME
	fi
fi

# prompt
if hash starship &>/dev/null; then
    eval "$(starship init bash)"
else
	PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '
	if [[ $(/usr/bin/tput colors) = 256 ]]; then
		displayPS1() {
			local rval=$?
			local -r rempath="\[\033]0;\u@\h: \w\007\]"
			if (( rval == 0 )); then
				unset rval
			else
				printf -v rval '\[\e[3;37m\](\[\e[1;31m\]%s\[\e[0m\]\[\e[3;37m\])\[\e[0m\] ' $rval
			fi
			PS1="${rempath}\[\e[3;37m\]\A (\u)\[\e[0m\] \[\e[3;32m\]\w\[\e[0m\]\n${rval}\\[\e[1;34m\]\$\[\e[0m\] \[$(tput sgr0)\]"
		}
	else
		displayPS1() {
			local rval=$?
			local -r rempath="\[\033]0;\u@\h: \w\007\]"
			if (( rval == 0 )); then
				unset rval
			else
				printf -v rval '(%s) ' $rval
			fi
			PS1="${rempath}\A (\u) \w\n${rval}\\$ \[$(tput sgr0)\]"
		}
	fi
	export PROMPT_COMMAND=displayPS1
fi

tma() {
	local sess='main'
	if (( $# > 0 )); then
		sess=$1
	fi
	command tmux new-session -A -s "${sess}" -t 'primary'
}

# utility functions
bashquote() { printf '%q\n' "$(</dev/stdin)"; }

# Source global definitions
if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

# shell options
set +H
shopt -s extglob
shopt -s lastpipe

[[ -f .bashrc.local ]] && source .bashrc.local || true

# vim: ft=bash ts=4 sw=4 noet
