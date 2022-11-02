# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
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
	fc-list : family spacing outline scalable |
		grep -E 'spacing=(100|90).*?outline=True.*?scalable=True' | cut -d':' -f1 | sort -u
}

fonttest() {
	echo -e "\e[1mbold\e[0m"
	echo -e "\e[3mitalic\e[0m"
	echo -e "\e[3m\e[1mbold italic\e[0m"
	echo -e "\e[4munderline\e[0m"
	echo -e "\e[9mstrikethrough\e[0m"
	echo -e "\e[31mHello World\e[0m"
	echo -e "\x1B[31mHello World\e[0m"
}

bashquote() {
	printf '%q\n' "$(</dev/stdin)"
}

up() {
	builtin cd "$(printf '../%.0s' $(seq 1 "$1"))" || return
	alias ..='up'
}

nocomment() {
	awk -F\# '$1!="" {print}' "$@"
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

deleted() {
	if has lsof; then
		sudo lsof / 2>/dev/null | grep '(deleted)' | grep -vE 'memfd|shm|/tmp|gvfs|flatpak|Metrics|\.log'
	fi
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

fsudo() {
	local -r arg=$1
	if [[ $(type -t "$arg") = 'function' ]]; then
		shift && command sudo bash -c "$(declare -f "$arg");$arg $*"
	elif [[ $(type -t "$arg") = 'alias' ]]; then
		local -r bak=$(alias sudo 2>/dev/null)
		alias sudo='\sudo '
		eval "sudo $*"

		if [[ -n $bak ]]; then
			eval "$bak"
		else
			unalias sudo
		fi
	else
		command sudo "$@"
	fi
}

listsans() {
	if [[ ! -r $1 ]]; then
		msg 'Could not open file.'
		return 1
	fi

	local -r sans=$(openssl x509 -in "$1" -noout -text | grep -A1 'Subject Alternative Name' | tail -n1 | tr -d ',')
	for san in $sans; do
		echo "$san" | cut -f2 -d:
	done
}

#shellcheck disable=2086
oomscore() {
	msg 'PID\tOOM Score\tOOM Adj\tCommand'
	while read -r pid comm; do
		if [[ -f /proc/$pid/oom_score ]]; then
			local score=$(</proc/${pid}/oom_score)
			local adj=$(</proc/${pid}/oom_score_adj)
			if ((score != 0)); then
				printf '%d\t%d\t\t%d\t%s\n' "$pid" "$score" "$adj" "$comm"
			fi
		fi
	done < <(ps -e -o pid= -o comm=) | sort -k 2nr
}

webget() {
	local dest=$PWD
	if has xdg-user-dir; then
		dest=$(xdg-user-dir DOWNLOAD)
		if [[ -z $dest ]]; then
			dest=$PWD
		fi
	fi
	if has curl; then
		if curl \
			--connect-timeout 5 \
			--location \
			--max-redirs 10 \
			--output-dir "${dest}" \
			--remote-header-name \
			--remote-name-all \
			--remove-on-error \
			"$@"; then
			msg 'File written to' "$dest"
		fi
	elif has wget; then
		wget \
			--continue \
			--content-disposition \
			--directory-prefix="${dest}" \
			--no-config \
			--no-hsts \
			--no-verbose \
			--timeout=5 \
			--trust-server-names \
			"$@"
	else
		msg 'Neither curl nor wget could be found.'
	fi
}