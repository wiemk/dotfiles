# vi:set ft=bash ts=4 sw=4 noet noai:

on_debug

# Create own scope for neovim and child processes
if has nvim; then
	if [[ -d /run/systemd/system && $CONTAINER != 1 ]]; then
		# Fedora sets vim alias
		unalias vim &>/dev/null
		unset -f vim

		function vim() {
			if ! type -t is_tmux &>/dev/null || ! is_tmux; then
				systemd-run --quiet --user --collect --scope nvim "$@"
			else
				tmux_rename_window vim nvim "$@"
			fi
		}
	else
		alias vim='nvim'
	fi
fi
