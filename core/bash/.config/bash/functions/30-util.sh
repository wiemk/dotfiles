# vi:set ft=bash ts=4 sw=4 noet noai:

trim() {
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"
	var="${var%"${var##*[![:space:]]}"}"
	printf '%s' "$var"
}
up() { cd $(printf '../%.0s' $(seq 1 $1)); }
alias ..='up'

bashquote() { printf '%q\n' "$(</dev/stdin)"; }

mem() { ps -eo rss,vsz,pid,euser,args --cols=100 --sort %mem \
	| grep -v grep \
	| grep -i "$@" \
	| awk '{
		rss=$1;vsz=$2;pid=$3;uid=$4;$1=$2=$3=$4="";sub(/^[ \t\r\n]+/, "", $0);
		printf("%d: (%s) # %s\n\tRSS: %8.2f M\n\tVSZ: %8.2f M\n", pid, uid, $0, rss/1024, vsz/1024);}'
}
