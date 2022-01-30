# vi:set ft=bash ts=4 sw=4 noet noai:
on_debug

if has starship; then
	eval "$(starship init bash)"
else
	if [[ -f /run/.toolboxenv ]]; then
		export TOOLBOX=1
	fi
	PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '

	if has tput && [[ $(/usr/bin/tput colors) = 256 ]]; then
		declare -a seq=(bold dim blink smul rmul rev smso rmso sgr0 tsl fsl)
		declare -A osc
		for i in "${seq[@]}"; do
			osc[$i]=$(tput $i)
		done
		declare -a col
		for c in {0..255}; do
			col[$c]=$(tput setaf $c);
		done

	displayPS1() {
		local rval=$?
		local -r norm=${osc[sgr0]}
		local -r dim=${osc[dim]}
		local -r bold=${osc[bold]}
		local -r remp="${osc[tsl]}\u@\h: \w${osc[fsl]}"
		if (( rval == 0 )); then
			unset rval
		else
			printf -v rval "(%s%s%d%s) " $bold ${col[1]} $rval $norm
		fi
		if (( TOOLBOX == 1 )); then
			printf -v tbox "%s%s⬢%s " $bold ${col[105]} $norm
		fi
		PS1="${tbox}${remp}${dim}\A${norm} ${col[105]}\u ${col[2]}\w${norm}\n${rval}${col[4]}\$${norm} "
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
			PS1="${tbox}${remp}\A (\u) \w\n${rval}\\$ \[\033[0;10m\]"
		}
	fi
	export PROMPT_COMMAND=displayPS1
fi
