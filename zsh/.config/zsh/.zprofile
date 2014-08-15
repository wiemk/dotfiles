# only sourced when shell is a login shell [[ -o login ]]
# keep compatibility with other shells and source ~/.profile if available
# for zsh specific environment changes prefer using .zshrc.pre as we are told by grml autors

[[ -r ~/.profile ]] && emulate sh -c 'source ~/.profile'

