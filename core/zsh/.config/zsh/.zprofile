# vi: set ft=zsh ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=marker:
#{{{General
has() {
	(( ${+commands[$1]} ))
}
# }}}
#{{{Variables
if [[ ! -v EDITOR ]]; then
	if has nvim; then
		EDITOR=nvim
	else
		EDITOR=vi
	fi
fi

PAGER=less
LESS='-F -g -i -M -R -S -w -X -z-4'
LESSHISTFILE=${XDG_CACHE_HOME}/lesshist
SYSTEMD_PAGER=cat

export EDITOR PAGER LESS LESSHISTFILE SYSTEMD_PAGER
#}}}
# {{{nix
# https://github.com/NixOS/nixpkgs/issues/149791
if has nix-env; then
	if has home-manager; then
		# export NIX_PATH=${HOME}/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
		# if targets.genericLinux.enable = false, source manually
		if [[ ! -v __HM_SESS_VARS_SOURCED && -e ${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
			source "${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh"
		fi
	fi

	if ! [[ $XDG_DATA_DIRS == *.nix-profile* ]]; then
		export XDG_DATA_DIRS=${HOME}/.nix-profile/share:${XDG_DATA_DIRS}
	fi
fi
#}}}
# {{{zprofile.local
# Set variables here (as an alternative to environment.d(5)
if [[ -e ${ZDOTDIR}/.zprofile.local ]]; then
	source "${ZDOTDIR}/.zprofile.local"
fi
# }}}