# only sourced when shell is a login shell [[ -o login ]]
# keep compatibility with other shells and source ~/.profile if available

if [[ -r $HOME/.profile ]]; then
	emulate sh -c 'source ~/.profile'
	#XDG_CONFIG_HOME isn't available here if it's a login shell
elif [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/profile/profile" ]]; then
	emulate sh -c "source ${XDG_CONFIG_HOME:-$HOME/.config}/profile/profile"
fi

# in case the .profile doesn't set XDG vars, set some sane defaults
# since they are important
: ${XDG_CONFIG_HOME:="$HOME/.config"}
: ${XDG_CACHE_HOME:="$HOME/.cache"}
: ${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME


# ZSH specific environmental variables and mechanisms
export ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh
export ZPLUG_HOME=$XDG_DATA_HOME/zplug

[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR
export HISTFILE=$ZSH_CACHE_DIR/zhistory
