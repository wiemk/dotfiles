# vi: set ft=zsh ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=marker nofoldenable:
#
# {{{Environment
# Wayland sources environment.d configuration fragments for us
if [[ $XDG_SESSION_TYPE != wayland \
	&& -x /usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator ]]; then
	export $(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator | xargs)
fi

# Don't rely on environment.d for prepending .local/bin and dedup items
path=($(readlink -eq "${XDG_DATA_HOME}/../bin") $path)
typeset -U path

# fallback
ZPLUGIN=${ZPLUGIN:-${XDG_STATE_HOME}/zsh/plugins}
if [[ ! -d $ZPLUGIN ]]; then
	command mkdir -p "${XDG_STATE_HOME}/zsh/plugins" 2>/dev/null || ZPLUGIN=$ZDOTDIR
fi
# }}}

# {{{Options
setopt \
	autocd \
	autoparamslash \
	autopushd \
	extendedglob \
	globcomplete \
	markdirs \
	pushdignoredups \
	pushdsilent \
	rmstarwait

unsetopt beep
# }}}

# {{{History
setopt \
	histfcntllock \
	histnofunctions \
	histnostore \
	histreduceblanks \
	sharehistory

unsetopt histsavebycopy

HISTFILE=${XDG_STATE_HOME}/zsh/history
HISTSIZE=10000
SAVEHIST=10000
# }}}

# {{{Title
if (( ${+terminfo[fsl]} && ${+terminfo[tsl]} )); then
	window-title() {
		title=${PWD##*/}
		if [[ ${#title} -gt 16 ]]; then
			title="${title:(-16)}"
		fi
		print -n "${terminfo[tsl]}${title}${terminfo[fsl]}"
	}
	autoload -Uz add-zsh-hook
	add-zsh-hook precmd window-title
fi
# }}}

# {{{Keybinds
bindkey -e

# https://wiki.archlinux.org/title/zsh#Key_bindings
# for additional keys see terminfo(5)
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# Some keys like C-<arrow> are default unsupported by terminfo but
# they exist as extended/user-defined capabilities (see info infocmp -x)
key[C-Home]=${terminfo[kHOM5]}
key[C-End]=${terminfo[kEND5]}
key[C-Up]=${terminfo[kUP5]}
key[C-Down]=${terminfo[kDN5]}
key[C-Left]=${terminfo[kLFT5]}
key[C-Right]=${terminfo[kRIT5]}

key[M-Home]=${terminfo[kHOM3]}
key[M-End]=${terminfo[kEND3]}
key[M-Up]=${terminfo[kUP3]}
key[M-Down]=${terminfo[kDN3]}
key[M-Left]=${terminfo[kLFT3]}
key[M-Right]=${terminfo[kRIT3]}

# setup key accordingly
[[ -n ${key[Home]}      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n ${key[End]}       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n ${key[Insert]}    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n ${key[Backspace]} ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n ${key[Delete]}    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n ${key[Up]}        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n ${key[Down]}      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n ${key[Left]}      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n ${key[Right]}     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n ${key[PageUp]}    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n ${key[PageDown]}  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n ${key[Shift-Tab]} ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
[[ -n ${key[C-Left]}    ]] && bindkey -- "${key[C-Left]}"     backward-word
[[ -n ${key[C-Right]}   ]] && bindkey -- "${key[C-Right]}"    forward-word
[[ -n ${key[C-Back]}    ]] && bindkey -- "${key[C-Back]}"     backward-kill-word

bindkey -- "^H" backward-kill-word

# Ensure terminal is in application mode
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
# }}}

# {{{help
unalias run-help 2>/dev/null
autoload run-help
HELPDIR=/usr/share/zsh/${ZSH_VERSION}/help
alias help=run-help
# }}}

# {{{GPG
# gpg-agent should be started by systemd but we need to refresh the tty
export GPG_TTY=$(tty)
gpgsock=$(gpgconf --list-dirs agent-socket 2>/dev/null)
if [[ -S $gpgsock ]]; then
	gpg-connect-agent updatestartuptty /bye >/dev/null
fi
unset gpgsock
# }}}

# {{{Functions
has() {
	(( ${+commands[$1]} ))
}

# needs call to stat(2)
ensure() {
	has "$1" && [[ -x $commands[$1] ]]
}

fload() {
	fpath=("${ZDOTDIR}/functions" $fpath)
	setopt local_options nonomatch
	autoload -Uz $fpath[1]/*(.:t)
}
fload
#}}}

# {{{Completion
autoload -Uz compinit
command mkdir -p "${XDG_CACHE_HOME}/zsh" 2>/dev/null
compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump"
# }}}

# {{{Plugins
if ! has git; then
	NO_CLONE=1
fi

# {{{Prompt
if has starship; then
  eval "$(command starship init zsh --print-full-init)"
else
	# fall back to minimal prompt
	if [[ ! -e ${ZPLUGIN}/minimal/minimal.zsh && ! -v NO_CLONE ]]; then
		GIT_CONFIG_GLOBAL=/dev/null git -C "$ZPLUGIN" clone --depth=1 https://github.com/subnixr/minimal.git
	fi
	source "${ZPLUGIN}/minimal/minimal.zsh"
fi
# }}}

# {{{fzf
if has fzf; then
	_source_xdg_data() {
		local args=("$@")
		local src
		if [[ -v XDG_DATA_DIRS ]]; then
			for dir in ${(@s/:/)XDG_DATA_DIRS}; do
				for file in $args; do
					src=$dir/$file
					src=${src:a}
					if [[ -r $src ]]; then
						source "$src"
						return
					fi
				done
			done
		fi

		# try system wide standard directory
		for file in $args; do
			src=/usr/share/${file}
			src=${src:a}
			if [[ -r $src ]]; then
				source "$src"
				return
			fi
		done

		# nothing found
		return 1
	}

	# Packager may have left completion.zsh untouched,
	# residing in fzf's data dir instead of zsh's (nix).
	# Don't append fpath, just source it.
	if _source_xdg_data zsh/site-functions/fzf fzf/completion.zsh; then
		if has fd; then
			_fzf_compgen_path() {
				fd --hidden --follow --exclude ".git" . "$1"
			}

			_fzf_compgen_dir() {
				fd --type d --hidden --follow --exclude ".git" . "$1"
			}
		fi
		_source_xdg_data fzf/{,shell}/key-bindings.zsh || true
	fi

	if [[ ! -e ${ZPLUGIN}/fzf-tab/fzf-tab.plugin.zsh && ! -v NO_CLONE ]]; then
		GIT_CONFIG_GLOBAL=/dev/null git -C "$ZPLUGIN" clone --depth=1 https://github.com/Aloxaf/fzf-tab.git
	fi
	source "${ZPLUGIN}/fzf-tab/fzf-tab.plugin.zsh"
	unset -f _source_xdg_data
fi
# }}}
#
# {{{zsh-autosuggestions
if [[ ! -e ${ZPLUGIN}/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh && ! -v NO_CLONE ]]; then
		GIT_CONFIG_GLOBAL=/dev/null git -C "$ZPLUGIN" clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git
fi
source "${ZPLUGIN}/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
ZSH_AUTOSUGGEST_STRATEGY+=(completion)
bindkey -- '^[[Z' autosuggest-accept
# }}}

# {{{zoxide
if has zoxide; then
	eval "$(command zoxide init zsh)"
	_zo_exclude_dirs=('/media/*' '/mnt/*' '/tmp/*' '*/.cache/*')

	zoxide-widget() {
		export _ZO_EXCLUDE_DIRS=${(j@:@)_zo_exclude_dirs}
		dir="$(command zoxide query -i -- "$@")"
		# BUFFER="builtin cd -- ${(q)dir}"
		# zle accept-line
		builtin cd -- "$dir"
		local ret=$?
		unset dir
		zle reset-prompt
		return $ret
	}
	zle -N zoxide-widget
	bindkey -M emacs '^G' zoxide-widget
fi

# {{{vivid
if [[ -n $VIVID_LS_THEME ]] && has vivid; then
	export LS_COLORS=$(vivid generate "$VIVID_LS_THEME" 2>/dev/null)
	# Fedora quirk
	export USER_LS_COLORS=$VIVID_LS_THEME
fi
# }}}
# }}}

# {{{Aliase
alias chgrp='command chgrp -c --preserve-root'
alias chmod='command chmod -c --preserve-root'
alias chown='command chown -c --preserve-root'

alias info='info --vi-keys'

alias l.='command ls -d .* --color=auto' 2>/dev/null
alias ll='command ls -l --color=auto' 2>/dev/null
alias ls='command ls --color=auto --show-control-chars --group-directories-first -AlhXF'
alias sl='ls'

alias cp='command cp -av'
alias ln='command ln -vi'
alias mkdir='command mkdir -v'
alias mv='command mv -v'
alias rm='command rm -vI'

alias dnf='sudo dnf'
alias dnfw='sudo dnf --setopt=install_weak_deps=False'
alias e='editor'
alias ed='editor'
alias edit='editor'
alias grep='grep --color=auto'
alias iface="ip route get 8.8.8.8 | sed -n '1 s/.* dev \([^ ]*\).*/\1/p'"
alias kc='koji-arch'
alias mm='neomutt'
alias mpvr="mpv --input-ipc-server=\${XDG_RUNTIME_DIR}/mpv.sock"
alias mutt='neomutt'
alias top='htop'
alias unsha='socat -t 5 - tcp:unsha.re:10000'
alias upd='plug-up'
#}}}

# {{{zshrc.local
if [[ -e ${ZDOTDIR}/.zshrc.local ]]; then
	source "${ZDOTDIR}/.zshrc.local"
fi
# }}}