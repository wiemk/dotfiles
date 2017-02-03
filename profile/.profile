# ~/.profile
# assume bash compatible shell

# let's be explicit here
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
if [[ -d "$HOME"/tmp ]]; then
    XDG_CACHE_HOME="$HOME"/tmp/.cache
else
    XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
fi
export XDG_CACHE_HOME
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}

# define additional PATH folders here
pathar=("$XDG_DATA_HOME"/../bin)
##
# PATH handling
if type realpath >/dev/null 2>&1; then
    for (( i=0; i < ${#pathar[@]}; i++ )); do
        pathar[$i]="$(realpath -s "${pathar[$i]}")"
    done
    unset i
fi
if [[ -n "$ZSH_VERSION" ]]; then
    emulate zsh -c 'path=($pathar $path)'
else
    path=("${pathar[@]}" "$PATH")
    path="$( printf '%s:' "${path[@]%/}" )"
    path="${path:0:-1}"
    export PATH="$path"
    unset path
fi
unset pathar


# default applications by env
export EDITOR=nvim
export SUDO_EDITOR='nvim -Z -u /dev/null'
export ALTERNATE_EDITOR=vim
export VISUAL=$EDITOR
export PAGER='less -M'
export LESSHISTFILE="$XDG_CACHE_HOME"/lesshist

if [[ -n "$ZSH_VERSION" ]]; then
	MACHINE=$HOST
else
	MACHINE=$HOSTNAME
fi
if [[ ! -z ${MACHINE+x} ]]; then
	source ".profile-$MACHINE"
fi
