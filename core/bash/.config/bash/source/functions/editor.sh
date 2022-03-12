# vi:set ft=bash ts=4 sw=4 noet noai:

on_debug

# Create own scope for neovim and child processes
if has $EDITOR; then
	if [[ -d /run/systemd/system && $CONTAINER != 1 ]]; then
		function edit() {
			if ! type -t is_tmux &>/dev/null || ! is_tmux; then
				systemd-run --quiet --user --collect --scope $EDITOR "$@"
			else
				tmux_rename_window edit systemd-run --quiet --user --collect --scope $EDITOR "$@"
			fi
		}
	else
		alias edit='$EDITOR'
	fi
fi

if has neovide; then
	function visual() {
		if has lvim; then
			local bin=$(command -v lvim)
		fi
		local cmd="neovide --nofork --multigrid --maximized ${bin:+--neovim-bin ${bin}}"
		if ! type -t is_tmux &>/dev/null || ! is_tmux; then
			systemd-run --quiet --user --collect --scope $cmd "$@"
		else
			tmux_rename_window edit systemd-run --quiet --user --collect --scope $cmd "$@"
		fi
	}
fi
