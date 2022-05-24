# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash

init_debug

sc-run() {
	systemd-run --quiet --user --collect "$@"
}

sc-running() {
	if (($# > 0)); then
		if [[ $1 == "--user" ]]; then
			local -r user=1
		else
			echo "Only --user is supported." >&2
			return 1
		fi
	fi

	systemctl ${user:+--user} list-units --type=service --state=running
}

jc-last() {
	if (($# < 1)); then
		echo "Function takes systemd unit name as argument." >&2
		return 1
	fi

	journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show --property=InvocationID --value "$1")"
}
# shellcheck disable=0-9999
_jc-last-compl() {
	local -r comps=$(journalctl --field=_SYSTEMD_UNIT 2>/dev/null)
	local cur=${COMP_WORDS[COMP_CWORD]}

	if ! [[ $cur =~ '\\' ]]; then
		cur="$(printf '%q' "$cur")"
	fi

	compopt -o filenames
	COMPREPLY=($(compgen -o filenames -W '$comps' -- "$cur"))
}
complete -F _jc-last-compl jc-last
