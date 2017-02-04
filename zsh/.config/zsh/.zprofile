# only sourced when shell is a login shell [[ -o login ]]
# keep compatibility with other shells and source ~/.profile if available

[[ -r ~/.profile ]] && emulate sh -c 'source ~/.profile'

# ZSH specific environmental variables and mechanisms
ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR
export HISTFILE=$ZSH_CACHE_DIR/zhistory
