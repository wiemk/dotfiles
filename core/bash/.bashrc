# shellcheck shell=bash

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bashrc' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
fi

if hash starship &>/dev/null; then
    eval "$(starship init bash)"
else
	PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '
	displayPS1() {
		local rval=$?
		if (( rval == 0 )); then
			unset rval
		else
			printf -v rval '(%s) ' $rval
		fi
		PS1="\A \w\n$rval\\$ \[$(tput sgr0)\]"
	}
	export PROMPT_COMMAND=displayPS1
fi

alias tma='fish -c tma'
alias tms='fish -c tms'

set +H
shopt -s extglob
shopt -s lastpipe

bashquote() { printf '%q\n' "$(</dev/stdin)"; }

# vim: ft=bash ts=4 sw=4 noet
