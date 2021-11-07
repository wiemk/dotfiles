# shellcheck shell=bash

if [[ -e "${XDG_CONFIG_HOME}/bash/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bash_profile' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

# load .profile since .bash_profile takes priority
# if [[ -f ~/.profile && -z $PROFILE_SOURCED ]]; then
if [[ -f ~/.profile ]]; then
	source ~/.profile
fi

# load .bashrc for aliases and functions in login shells
if [[ -f ~/.bashrc ]]; then
	source ~/.bashrc
fi

# vim: ft=bash ts=4 sw=4 noet
