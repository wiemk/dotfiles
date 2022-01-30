# vi:set ft=bash ts=4 sw=4 noet noai:
on_debug

up() {
	cd $(printf '../%.0s' $(seq 1 $1));
}
alias ..='up'

prompt() {
	read -rp "${1} (y/n) " choice
	case "$choice" in 
		y|Y ) return 0;;
		n|N ) return 1;;
		* ) return 1;;
	esac
}

bashquote() {
	printf '%q\n' "$(</dev/stdin)";
}

mem() { ps -eo rss,vsz,pid,euser,args --cols=100 --sort %mem \
	| grep -v grep \
	| grep -i "$@" \
	| awk '{
		rss=$1;vsz=$2;pid=$3;uid=$4;$1=$2=$3=$4="";sub(/^[ \t\r\n]+/, "", $0);
		printf("%d: (%s) # %s\n\tRSS: %8.2f M\n\tVSZ: %8.2f M\n", pid, uid, $0, rss/1024, vsz/1024);}'
}

netns() {
	local -r ns=$1
	shift 1

	if has firejail; then
		firejail --quiet --noprofile --rmenv=LS_COLORS --netns="$ns" "$@"
	else
		sudo -E ip netns exec "$ns" setpriv --reuid "$UID" --regid "${GROUPS[0]}" --clear-groups --reset-env "$@"
	fi
}

ansi_colors() {
	for c in {0..255}; do
		tput setaf $c
	   	tput setaf $c | cat -v
		echo " =${c}"
	done
}
