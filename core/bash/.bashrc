# vi:set ft=bash ts=4 sw=4 noet noai:

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bashrc' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

# Settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=5000

shopt -s histappend
shopt -s extglob
shopt -s lastpipe
shopt -s direxpand

has() {
	if hash "${1}" &>/dev/null; then
		return 0
	fi
	return 1
}

if [[ -f /run/.containerenv ]] || systemd-detect-virt --quiet --container; then
	export CONTAINER=1
fi

# Prompt
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
			if [[ $TOOLBOX == 1 ]]; then
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
			if [[ $TOOLBOX == 1 ]]; then
				local -r tbox="\[\033[35m\]⬢\[\033[0m\] "
			fi
			PS1="${tbox}${remp}\A (\u) \w\n${rval}\\$ \[$(tput sgr0)\]"
		}
	fi
	export PROMPT_COMMAND=displayPS1
fi

# Source global config *after* prompt definition
if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

# Functions
up() { cd $(printf '../%.0s' $(seq 1 $1)); }
bashquote() { printf '%q\n' "$(</dev/stdin)"; }
mem() { ps -eo rss,vsz,pid,euser,args --cols=100 --sort %mem \
	| grep -v grep \
	| grep -i "$@" \
	| awk '{
		rss=$1;vsz=$2;pid=$3;uid=$4;$1=$2=$3=$4="";sub(/^[ \t\r\n]+/, "", $0);
		printf("%d: (%s) # %s\n\tRSS: %8.2f M\n\tVSZ: %8.2f M\n", pid, uid, $0, rss/1024, vsz/1024);}'
}
## Attach tmux
tma() {
	local sess='main'
	if (( $# > 0 )); then
		sess=$1
	fi
	command tmux new-session -A -s "${sess}"
}

trim() {
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"
	var="${var%"${var##*[![:space:]]}"}"
	printf '%s' "$var"
}

## Redraw prompt line
__ehc()
{
	if [[ -n $1 ]]; then
		bind '"\er": redraw-current-line'
		bind '"\e^": magic-space'
		READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
		READLINE_LINE=$(trim "$READLINE_LINE")
		READLINE_POINT=$(( READLINE_POINT + ${#1}))
	else
		bind '"\er":'
		bind '"\e^":'
	fi
}

## zoxide fast jump
if has zoxide; then
	eval "$(zoxide init bash)"
	if has fzf; then
		bind '"\C-x": "\C-x2\e^\er"'
		bind '"\C-xx": "\C-x2\e^\er"'
		bind -x '"\C-x2": zi';
	fi
fi

## fzf utilities
if has fzf; then
	# https://github.com/junegunn/fzf/wiki/examples#command-history
	bind '"\C-r": "\C-x1\e^\er"'
	bind -x '"\C-x1": __fzf_history';

	__fzf_history () {
		__ehc "$(history | fzf --tac --tiebreak=index | grep -oP '^\s*([0-9]+)\s+\K.*$')"
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

# Dircolors matching theme
if [[ -n $VIVID_LS_THEME ]] && has vivid; then
	# fedora uses this variable to detect custom LS_COLORS
	LS_COLORS="$(vivid generate "$VIVID_LS_THEME" 2>/dev/null)"
	if [[ -n $LS_COLORS ]]; then
		export LS_COLORS
		export USER_LS_COLORS=$VIVID_LS_THEME
	fi
fi

# Aliase
alias ..='up'
# Create own scope for neovim and child processes
if has nvim; then
	if [[ -d /run/systemd/system && $CONTAINER != 1 ]]; then
		alias vim='systemd-run --quiet --user --collect --scope nvim'
	else
		alias vim='nvim'
	fi
fi

if [[ -f ~/.bashrc.local ]]; then
	source ~/.bashrc.local
fi

