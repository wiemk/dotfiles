# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

sc-run() {
	systemd-run --quiet --user --collect --pty "$@"
}

sc-run-idle() {
	systemd-run --quiet --user --collect --pty --nice=19 --property=CPUSchedulingPolicy=idle --property=IOSchedulingClass=idle "$@"
}

sc-run-bg() {
	systemd-run --quiet --user --collect "$@"
}

sc-run-idle-bg() {
	systemd-run --quiet --user --collect --nice=19 --property=CPUSchedulingPolicy=idle --property=IOSchedulingClass=idle "$@"
}

sc-running() {
	if (($# > 0)); then
		if [[ $1 == --user ]]; then
			local -r user=1
		else
			msg 'Only --user is supported.'
			return 1
		fi
	fi

	systemctl ${user:+--user} list-units --type=service --state=running
}

jc-last() {
	if (($# < 1)); then
		msg 'Function takes systemd unit name as argument.'
		return 1
	fi

	journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show --property=InvocationID --value "$1")"
}
# shellcheck disable=0-9999
_jc-last-compl() {
	local -r comps=$(journalctl --field=_SYSTEMD_UNIT 2>/dev/null)
	local cur=${COMP_WORDS[COMP_CWORD]}

	if ! [[ $cur =~ '\\' ]]; then
		cur=$(printf '%q' "$cur")
	fi

	compopt -o filenames
	COMPREPLY=($(compgen -o filenames -W '$comps' -- "$cur"))
}
complete -F _jc-last-compl jc-last