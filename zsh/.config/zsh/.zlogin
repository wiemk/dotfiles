# .zlogin
# debug
if [[ -e "${ZDOTDIR}/_debug" ]]; then
	echo "$(date +%s) .zlogin" >> "${HOME}/zsh_debug.log"
fi
# EOF
