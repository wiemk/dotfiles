# .zprofile
# only sourced when shell is a login shell, [[ -o login ]]
# keep compatibility with other shells and source ~/.profile if available
# doesn't get sourced by most display manager (use .xprofile)

# debug
if [[ -e "${ZDOTDIR}/_debug" ]]; then
	echo "$(date +%s): .zprofile" >> "${HOME}/shell_debug.log"
fi

if [[ -r "${HOME}/.profile" ]]; then
	emulate sh -c 'source ~/.profile'
	#XDG_CONFIG_HOME isn't available here if it's a login shell
elif [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/profile/profile" ]]; then
	emulate sh -c "source ${XDG_CONFIG_HOME:-$HOME/.config}/profile/profile"
fi

# in case the .profile doesn't set XDG vars, set some sane defaults
# since they are important
: ${XDG_CONFIG_HOME:="${HOME}/.config"}
: ${XDG_CACHE_HOME:="${HOME}/.cache"}
: ${XDG_DATA_HOME:="${HOME}/.local/share"}
typeset -gx XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME

# ZSH specific environmental variables and mechanisms
: ${ZSH_CACHE_DIR:="${XDG_CACHE_HOME}/zsh"}
: ${ZPLUG_HOME:="${XDG_DATA_HOME}/zplug"}

typeset -gx ZSH_CACHE_DIR ZPLUG_HOME

[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR
: ${HISTFILE:="${ZSH_CACHE_DIR}/zhistory"}
typeset -gx HISTFILE
#export ZPROFILE_SOURCED=true

#  vim: set ft=zsh ts=4 sw=4 sts=0 tw=0 noet :
# EOF
