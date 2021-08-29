# shellcheck shell=bash

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bashrc' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

# shell options
set +H
shopt -s extglob
shopt -s lastpipe
shopt -s direxpand

is_cmd() {
	if hash "${1}" &>/dev/null; then
		return 0
	fi
	return 1
}

# dircolors
if [[ -n $VIVID_LS_THEME ]] && is_cmd vivid; then
	# fedora uses this variable to detect custom LS_COLORS
	LS_COLORS="$(vivid generate "$VIVID_LS_THEME" 2>/dev/null)"
	if [[ -n $LS_COLORS ]]; then
		export LS_COLORS
		export USER_LS_COLORS=$VIVID_LS_THEME
	fi
fi

if [ -f /run/.containerenv ] \
   && [ -f /run/.toolboxenv ]; then
    export CONTAINER=1
fi

# prompt
if is_cmd starship; then
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
			if [[ $CONTAINER == 1 ]]; then
				local -r container="\[\033[35m\]⬢\[\033[0m\] "
			fi
			PS1="${container}${rempath}\[\e[3;37m\]\A (\u)\[\e[0m\] \[\e[3;32m\]\w\[\e[0m\]\n${rval}\\[\e[1;34m\]\$\[\e[0m\] \[$(tput sgr0)\]"
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
			if [[ $CONTAINER == 1 ]]; then
				local -r container="\[\033[35m\]⬢\[\033[0m\] "
			fi
			PS1="${container}${rempath}\A (\u) \w\n${rval}\\$ \[$(tput sgr0)\]"
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
up() { cd $(printf '../%.0s' $(seq 1 $1)); }
alias ..='up'

# Source global definitions
if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

if is_cmd zoxide; then
	eval "$(zoxide init bash)"
	if is_cmd fzf; then
		bind '"\er": redraw-current-line'
		bind '"\C-x": "zi\e\C-e\r"'
		bind '"\C-xx": "zi\r\e\C-e\er"'
	fi
fi

[[ -f .bashrc.local ]] && source .bashrc.local || true

# vim: ft=bash ts=4 sw=4 noet
