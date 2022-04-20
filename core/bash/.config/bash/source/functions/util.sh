# vi:set ft=bash ts=4 sw=4 noet noai:
# shellcheck shell=bash
# shellcheck disable=2155,1090

on_debug

ansi-colors() {
	for c in {0..255}; do
		tput setaf "$c"
		tput setaf "$c" | cat -v
		echo " =${c}"
	done
}

bashquote() {
	printf '%q\n' "$(</dev/stdin)"
}

if has secret-tool; then
	get-secret() {
		local -r kv=$1
		readarray -td : arr < <(printf "%s\0" "$kv")
		secret-tool lookup "${arr[0]}" "${arr[1]}"
	}
else
	# shim to avoid further checks
	get-secret() {
		printf "%s" "$*"
	}
fi

srun() {
	systemd-run --quiet --user --collect "$@"
}

up() {
	builtin cd "$(printf '../%.0s' $(seq 1 "$1"))" || return
	alias ..='up'
}

mem() {
	#shellcheck disable=2009
	ps -eo rss,vsz,pid,euser,args --cols=100 --sort %mem \
		| grep -v grep \
		| grep -i "$@" \
		| awk '{
			rss=$1;vsz=$2;pid=$3;uid=$4;$1=$2=$3=$4="";sub(/^[ \t\r\n]+/, "", $0);
			printf("%d: (%s) # %s\n\tRSS: %8.2f M\n\tVSZ: %8.2f M\n",
		   	pid, uid, $0, rss/1024, vsz/1024);
		}'
}

prompt() {
	read -rp "${1} (y/n) " choice
	case "$choice" in
	y | Y) return 0 ;;
	n | N) return 1 ;;
	*) return 1 ;;
	esac
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

share() {
	local resp=$(ncat unsha.re 9999 | tee /dev/fd/2 \
		| jq -r '{ expires, secret, url } | to_entries | .[] | "local " + .key + "=" + (.value | @sh)')

	if [[ -n $resp ]]; then
		eval "$resp"
		#shellcheck disable=2154
		xclip -i -select clipboard <(echo "$url")

		if has notify-send; then
			notify-send "Link copied to clipboard" 2>/dev/null
		fi
	fi
}

if has xfreerdp; then
	rdp() {
		local store=$3
		store=$(get-secret "rdp:${store}")
		if [[ -z $store ]]; then
			store=$3
		fi

		srun xfreerdp \
			/network:auto /rfx /dvc:echo /w:1600 /h:900 /dvc:echo /geometry /cert:ignore \
			+compression +async-channels +async-input -encryption -grab-keyboard \
			/v:"${1}" /u:"${2}" /p:"${store}" "${@:4}"
	}
fi

if has scrcpy; then
	scc() {
		srun scrcpy --max-size 1600 --bit-rate 12M --max-fps 60 --stay-awake --turn-screen-off "$@"
	}
fi

if has xprop && has xdotool; then
	xnobar() {
		local -r window=$(xdotool getactivewindow)
		xprop -id "$window" -f _MOTIF_WM_HINTS 32c \
			-set _MOTIF_WM_HINTS '0x2, 0x0, 0x0, 0x0, 0x0'

	}
fi

