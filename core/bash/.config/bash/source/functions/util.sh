# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash
# shellcheck disable=2155,1090

init_debug

lsansi() {
	for c in {0..255}; do
		tput setaf "$c"
		tput setaf "$c" | cat -v
		echo " =${c}"
	done
}

lsmono() {
	fc-list : family spacing outline scalable | \
		grep -E 'spacing=(100|90).*?outline=True.*?scalable=True' | cut -d':' -f1 | sort -u
}

bashquote() {
	printf '%q\n' "$(</dev/stdin)"
}

up() {
	builtin cd "$(printf '../%.0s' $(seq 1 "$1"))" || return
	alias ..='up'
}

ps() {
	if (($# > 0)); then
		command ps "$@"
	else
		command ps -eF
	fi
}

calc() {
	local result=$(printf "scale=10;%s\n" "$*" | bc --mathlib | tr -d '\\\n')
	#                       └─ default (when `--mathlib` is used) is 20
	if [[ $result == *.* ]]; then
		# improve the output for decimal numbers
		printf '%s' "$result" |
			sed -e 's/^\./0./' `# add "0" for cases like ".5"` \
				-e 's/^-\./-0./' `# add "0" for cases like "-.5"` \
				-e 's/0*$//;s/\.$//' `# remove trailing zeros`
	else
		printf '%s' "$result"
	fi
	printf '\n'
}

escape() {
	# shellcheck disable=2046
	printf "\\\x%s" $(printf '%s' "$*" | xxd -p -c1 -u)
	printf '\n'
}


con() {
	if has lsof; then
		if ((UID != 0)); then
			local -r priv=1
		fi
		local pids=$(pidof -S',' "$1")
		if [[ -n $pids ]]; then
			${priv:+sudo} lsof -r1 -iTCP -a -P -p "$pids"
		fi
	fi
}

mem() {
	#shellcheck disable=2009
	ps -eo rss,vsz,pid,euser,args --cols=100 --sort %mem |
		grep -v grep |
		grep -i "$@" |
		awk '{
			rss=$1;vsz=$2;pid=$3;uid=$4;$1=$2=$3=$4="";sub(/^[ \t\r\n]+/, "", $0);
			printf("%d: (%s) # %s\n\tRSS: %8.2f M\n\tVSZ: %8.2f M\n",
		   	pid, uid, $0, rss/1024, vsz/1024);
		}'
}

netns() {
	local -r ns=$1
	shift 1

	if has firejail; then
		firejail --quiet --noprofile --rmenv=LS_COLORS --netns="$ns" "$@"
	else
		sudo -E ip netns exec "$ns" \
			setpriv --reuid "$UID" --regid "${GROUPS[0]}" --clear-groups --reset-env "$@"
	fi
}
