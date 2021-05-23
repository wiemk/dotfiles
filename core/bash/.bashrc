# shellcheck shell=bash

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bashrc' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

# Source global definitions
if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

if hash starship &>/dev/null; then
    eval "$(starship init bash)"
else
	PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '
	if [[ $(/usr/bin/tput colors) = 256 ]]; then
		displayPS1() {
			local rval=$?
			if (( rval == 0 )); then
				unset rval
			else
				printf -v rval '\[\e[3;37m\](\[\e[1;31m\]%s\[\e[0m\]\[\e[3;37m\])\[\e[0m\] ' $rval
			fi
			PS1="\[\e[3;37m\]\A (\u)\[\e[0m\] \[\e[3;32m\]\w\[\e[0m\]\n${rval}\\[\e[1;34m\]\$\[\e[0m\] \[$(tput sgr0)\]"
		}
	else
		displayPS1() {
			local rval=$?
			if (( rval == 0 )); then
				unset rval
			else
				printf -v rval '(%s) ' $rval
			fi
			PS1="\A (\u) \w\n${rval}\\$ \[$(tput sgr0)\]"
		}
	fi
	export PROMPT_COMMAND=displayPS1
fi

alias tma='fish -c tma'

set +H
shopt -s extglob
shopt -s lastpipe

bashquote() { printf '%q\n' "$(</dev/stdin)"; }

# vim: ft=bash ts=4 sw=4 noet
