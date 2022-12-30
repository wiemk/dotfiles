# vi: set ft=zsh ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=marker:
#
# Fallback, set in ~/.config/environment.d/*.conf instead.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$(readlink -sf $XDG_DATA_HOME/../state)}

ZPLUGIN=${XDG_STATE_HOME}/zsh/plugins
# Pointless, if not set we wouldn't be here
ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}