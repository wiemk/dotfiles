# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

# Init window title (ssh, ..)
if [[ -z $PROMPT_COMMAND ]]; then
	case $TERM in
	xterm* | vte* | alacritty | kitty)
		PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
		;;
	tmux* | screen*)
		PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
		;;
	*) ;;
	esac
fi

if has starship; then
	eval "$(starship init bash)"
else
	PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '

	if has tput && [[ $(/usr/bin/tput colors) = 256 ]]; then
		declare -a seq=(bold dim blink smul rmul rev smso rmso sgr0 tsl fsl)
		declare -A osc
		for i in "${seq[@]}"; do
			osc[$i]="\[$(tput "$i")\]"
		done

		declare -A col
		col[red]="\[$(tput setaf 1)\]"
		col[green]="\[$(tput setaf 2)\]"
		col[blue]="\[$(tput setaf 4)\]"
		col[purple]="\[$(tput setaf 105)\]"

		displayPS1() {
			local rval=$?
			local -r norm=${osc[sgr0]}
			local -r dim=${osc[dim]}
			local -r bold=${osc[bold]}
			local -r remp="${osc[tsl]}\u@\h: \w${osc[fsl]}"
			if ((rval == 0)); then
				unset rval
			else
				printf -v rval "(%s%s%d%s) " "$bold" "${col[red]}" "$rval" "$norm"
			fi
			if [[ -v CONTAINER ]]; then
				printf -v cont "%s%s[$CONTAINER]%s " "$bold" "${col[purple]}" "$norm"
			fi
			PS1="${cont}${remp}${dim}\A${norm} ${col[purple]}\u ${col[green]}\w${norm}\n${rval}${col[blue]}\$${norm} "
		}
	else
		displayPS1() {
			local rval=$?
			local -r remp="\[\033]0;\u@\h: \w\007\]"
			if ((rval == 0)); then
				unset rval
			else
				printf -v rval '(%s) ' $rval
			fi
			if [[ -v CONTAINER ]]; then
				local -r cont="\[\033[35m\][$CONTAINER]\[\033[0m\] "
			fi
			PS1="${cont}${remp}\A (\u) \w\n${rval}\\$ \[\033[0;10m\]"
		}
	fi
	export PROMPT_COMMAND=displayPS1
fi