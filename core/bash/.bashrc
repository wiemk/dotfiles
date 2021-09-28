# shellcheck shell=bash

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bashrc' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=5000

shopt -s histappend
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

# Source global definitions
if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

# utility functions
tma() {
	local sess='main'
	if (( $# > 0 )); then
		sess=$1
	fi
	command tmux new-session -A -s "${sess}" -t 'primary'
}

bashquote() { printf '%q\n' "$(</dev/stdin)"; }
up() { cd $(printf '../%.0s' $(seq 1 $1)); }
alias ..='up'

__ehc()
{
	if [[ -n $1 ]]; then
		bind '"\er": redraw-current-line'
		bind '"\e^": magic-space'
		READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
		READLINE_POINT=$(( READLINE_POINT + ${#1} ))
	else
		bind '"\er":'
		bind '"\e^":'
	fi
}

if is_cmd zoxide; then
	eval "$(zoxide init bash)"
	if is_cmd fzf; then
		bind '"\C-x": "\C-x2\e^\er"'
		bind '"\C-xx": "\C-x2\e^\er"'
		bind -x '"\C-x2": zi';
	fi
fi

if is_cmd fzf; then
	# https://github.com/junegunn/fzf/wiki/examples#command-history
	bind '"\C-r": "\C-x1\e^\er"'
	bind -x '"\C-x1": __fzf_history';

	__fzf_history ()
	{
		__ehc "$(history | fzf --tac --tiebreak=index | perl -ne 'm/^\s*([0-9]+)/ and print "!$1"')"
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
fi

if [[ -f ~/.bashrc.local ]]; then
	source ~/.bashrc.local
fi

# vim: ft=bash ts=4 sw=4 noet
