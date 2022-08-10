# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

# Create own scope for neovim and child processes
if has "$EDITOR"; then
	if [[ -d /run/systemd/system && -z $CONTAINER ]]; then
		edit() {
			if ! type -t is_tmux &>/dev/null || ! is_tmux; then
				systemd-run --quiet --user --collect --scope "$EDITOR" "$@"
			else
				tmux_rename_window edit systemd-run --quiet --user --collect --scope "$EDITOR" "$@"
			fi
		}
	else
		alias edit='$EDITOR'
	fi
fi

if has neovide; then
	visual() {
		if has lvim; then
			local -r bin=$(command -v lvim)
		fi
		local cmd="neovide --nofork --multigrid --maximized ${bin:+--neovim-bin ${bin}}"
		if ! type -t is_tmux &>/dev/null || ! is_tmux; then
			systemd-run --quiet --user --collect --scope "$cmd" "$@"
		else
			tmux_rename_window edit systemd-run --quiet --user --collect --scope "$cmd" "$@"
		fi
	}
fi