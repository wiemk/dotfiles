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

# agents (gnome-keyring-daemon -s output)
export GPG_AGENT_INFO=${XDG_RUNTIME_DIR:-/run/user/$UID}/keyring/gpg:0:1
export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR:-/run/user/$UID}/keyring/ssh

export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
export MPV_HOME="$XDG_CONFIG_HOME"/mpv
export TIGRC_USER="$XDG_CONFIG_HOME"/tigrc

# apparently breaks lightdm
#export XAUTHORITY="$XDG_RUNTIME_DIR"/X11-authority
export XCOMPOSEFILE="$XDG_CONFIG_HOME"/X11/xcompose
export PENTADACTYL_RUNTIME="$XDG_CONFIG_HOME"/pentadactyl
export PENTADACTYL_INIT=":source $PENTADACTYL_RUNTIME/pentadactylrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/settings.ini

# at-spi annoyance fix
export NO_AT_BRIDGE=1

# default applications by env
export EDITOR='gvim -f'
export ALTERNATE_EDITOR='vim'
export PAGER=less
export LESSHISTFILE="$XDG_CACHE_HOME"/lesshist
export BROWSER=chromium
export TERMINAL=termite

# uim
export GTK_IM_MODULE=uim
export XMODIFIERS=@im=uim

# Disable Mono and Gecko installation and .desktop creation
export WINEDLLOVERRIDES="winemenubuilder.exe,mscoree,mshtml=d"
export WINEARCH=win32
export WINEDEBUG=-all
export WINEPREFIX="$XDG_DATA_HOME"/wine/default
export GREP_OPTIONS=--color=auto
export LESS=-R
export SDL_AUDIODRIVER=pulse

# ABS
export ABSROOT="$HOME"/dev/build/arch/abs

# systemd --user environment would be executed too late,
# so source ~/.profile with /etc/systemd/system/user@.service
# overriding /usr/lib/systemd/system/user@.service

# EOF
# vim :set ft=bash ts=4 sw=4 sts=4 et :
