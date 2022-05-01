# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash
# shellcheck disable=2155,1090

if [[ -e "${XDG_CONFIG_HOME}/bash/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .bash_profile' >>"${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

# load .profile since .bash_profile takes priority
# if [[ -f ~/.profile && -z $PROFILE_SOURCED ]]; then
if [[ -f ~/.profile ]]; then
	source ~/.profile
fi

# only load .bashrc for aliases and functions in
# login shells if shell is interactive
case "$-" in *i*)
	if [[ -r ~/.bashrc ]]; then
		source ~/.bashrc
	fi
	;;
esac
