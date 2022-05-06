# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash

on_debug

if ! has tmux; then
	return
fi

tma() {
	local sess='main'
	if (($# > 0)); then
		sess=$1
	fi
	command tmux new-session -A -s "${sess}"
}

is_tmux() {
	local -r tm=$(ps -p "$(ps -p $$ -o ppid= | xargs -n 1)" -o comm=)
	[[ $tm == "tmux"* ]]
}

tmux_rename_window() {
	local -r title=$1
	local -r cmd=$2
	shift 2

	if ! is_tmux; then
		eval "command $cmd $*"
		return
	fi

	# no rename when splits exist
	local -ri panes="$(command tmux display-message -p '#{window_panes}')"
	if ((panes > 1)); then
		eval "command $cmd $*"
		return
	fi

	_tmux_pty_to_pane_id() {
		local -r tty=$1
		while read -r pane; do
			local pane_id=${pane#*:}
			local pane_tty=${pane%:*}
			if [[ $tty == "$pane_tty" ]]; then
				echo "$pane_id"
			fi
		done < <(command tmux list-panes -aF "#{pane_tty}:#{pane_id}")
	}

	local -r pane_id=$(_tmux_pty_to_pane_id "$(tty)")
	if [[ -z $pane_id ]]; then
		eval "command $cmd $*"
		return
	fi

	command tmux rename-window -t "$pane_id" "$title"
	command $cmd "$@"
	command tmux set-option -qwp -t "$pane_id" automatic-rename 'on'
}

# ssh wrapper for renaming window
ssh() {
	local param=("$@")

	if ! has rg || ! is_tmux; then
		eval "command ssh $*"
		return
	fi

	local -r dest="${param[-1]}"
	local -r host=$(rg --no-config --color=never --pcre2 --only-matching --replace '$2' \
		'^(?:((?:[a-z_](?:[a-z0-9_-]{0,31}|[a-z0-9_-]{0,30})?))\@)?((?:[a-z0-9]+[a-z0-9\-\.\:]*[a-z0-9]+)+)$' \
		< <(echo "$dest"))

	if [[ -n $host ]]; then
		tmux_rename_window "{${host}}" ssh "$@"
	else
		eval "command ssh $*"
	fi
}
