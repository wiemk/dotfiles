ZPLUG_CACHE_DIR=$ZSH_CACHE_DIR
# crude, live with it
if [[ ! -a $ZPLUG_HOME/init.zsh ]]; then
	env git clone --depth=1 "https://github.com/zplug/zplug" $ZPLUG_HOME
	zplug update --self
fi
# load zplug
source "${ZPLUG_HOME}/init.zsh"

## plugins
# prompt theme
zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme
PURE_PROMPT_SYMBOL='>'
PURE_GIT_UP_ARROW='↑'
PURE_GIT_DOWN_ARROW='↓'

# some prezto settings in order to kickstart zsh
zplug 'modules/environment', from:prezto
zplug 'modules/terminal', from:prezto
zplug 'modules/editor', from:prezto
zplug 'modules/history', from:prezto
zplug 'modules/directory', from:prezto
zplug 'modules/utility', from:prezto
zplug 'modules/completion', from:prezto
zplug 'modules/git', from:prezto
zplug 'modules/tmux', from:prezto

zstyle ':prezto:*:*' color 'yes'
zstyle ':prezto:module:terminal' auto-title 'yes'
zstyle ':prezto:module:editor' dot-expansion 'yes'
zstyle ':prezto:module:tmux:auto-start' local 'yes'
zstyle ':prezto:module:tmux:auto-start' remote 'yes'

if (( $+commands[fzf] )); then
	if [[ -d '/usr/share/fzf' ]]; then
		zplug '/usr/share/fzf', from:local, use:"*.zsh"
		#zplug '/usr/bin', from:local, use:'fzf-tmux'
	else
		zplug 'junegunn/fzf', use:"shell/*.zsh"
		zplug 'junegunn/fzf', as:command, use:'bin/fzf-tmux'
	fi
fi

# WARNING: this introduces a rather large (300-500ms) delay
# after every command executed, but it's worth it if you have
# a large alias database and bad memory
zplug 'djui/alias-tips'
export ZSH_PLUGINS_ALIAS_TIPS_TEXT='💡	Try: '

# custom enabled functions
zplug "${ZDOTDIR}/func-enabled", from:local, use:"*.zsh"

zplug 'zsh-users/zsh-syntax-highlighting', defer:2
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root)
zplug "zsh-users/zsh-history-substring-search", defer:3
if zplug check "zsh-users/zsh-history-substring-search"; then
	zmodload zsh/terminfo
	[ -n "${terminfo[kcuu1]}" ] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
	[ -n "${terminfo[kcud1]}" ] && bindkey "${terminfo[kcud1]}" history-substring-search-down
	bindkey -M emacs '^P' history-substring-search-up
	bindkey -M emacs '^N' history-substring-search-down
	bindkey -M vicmd 'k' history-substring-search-up
	bindkey -M vicmd 'j' history-substring-search-down
fi

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
	printf "Install? [y/N]: "
	if read -q; then
		echo; zplug install
	fi
fi

# unintrusive modules and functions
zmodules=(attr stat)
zfunctions=(zmv zargs)
for zmodule ("$zmodules[@]") zmodload "zsh/${(z)zmodule}"
for zfunction ("$zfunctions[@]") autoload -Uz "${(z)zfunction}"
unset zmodule{s,} zfunction{s,}

# Then, source plugins and add commands to $PATH
#zplug load --verbose
zplug load

#EOF
