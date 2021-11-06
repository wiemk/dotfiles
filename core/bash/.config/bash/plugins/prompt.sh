# vi:set ft=bash ts=4 sw=4 noet noai:

if has starship; then
    eval "$(starship init bash)"
else
	if [[ -f /run/.toolboxenv ]]; then
		export TOOLBOX=1
	fi
	PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '
	if [[ $(/usr/bin/tput colors) = 256 ]]; then
		displayPS1() {
			local rval=$?
			local -r remp="\[\033]0;\u@\h: \w\007\]"
			if (( rval == 0 )); then
				unset rval
			else
				printf -v rval '\[\e[3;37m\](\[\e[1;31m\]%s\[\e[0m\]\[\e[3;37m\])\[\e[0m\] ' $rval
			fi
			if (( TOOLBOX == 1 )); then
				local -r tbox="\[\033[35m\]⬢\[\033[0m\] "
			fi
			PS1="${tbox}${remp}\[\e[3;37m\]\A (\u)\[\e[0m\] \[\e[3;32m\]\w\[\e[0m\]\n${rval}\\[\e[1;34m\]\$\[\e[0m\] \[$(tput sgr0)\]"
		}
	else
		displayPS1() {
			local rval=$?
			local -r remp="\[\033]0;\u@\h: \w\007\]"
			if (( rval == 0 )); then
				unset rval
			else
				printf -v rval '(%s) ' $rval
			fi
			if (( TOOLBOX == 1 )); then
				local -r tbox="\[\033[35m\]⬢\[\033[0m\] "
			fi
			PS1="${tbox}${remp}\A (\u) \w\n${rval}\\$ \[$(tput sgr0)\]"
		}
	fi
	export PROMPT_COMMAND=displayPS1
fi
