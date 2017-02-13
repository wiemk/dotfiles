# .zlogin
#
# debug
if [[ -e "${ZDOTDIR}/_debug" ]]; then
	echo "$(date +%s): .zlogin" >> "${HOME}/shell_debug.log"
fi

#  vim: set ft=zsh ts=4 sw=4 sts=0 tw=0 noet :
# EOF
