# .bashrc

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
fi

alias tma='fish -c tma'
alias tms='fish -c tms'

set +H
shopt -s extglob

bashquote() { printf '%q\n' "$(</dev/stdin)"; }

# vim: ts=4:sw=4:noet:ft=sh
# EOF
