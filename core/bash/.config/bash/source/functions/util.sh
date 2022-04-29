# vi:set ft=sh ts=4 sw=4 noet noai:
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
	ps -eo rss,vsz,pid,euser,args --cols=100 --sort %mem |
		grep -v grep |
		grep -i "$@" |
		awk '{
			rss=$1;vsz=$2;pid=$3;uid=$4;$1=$2=$3=$4="";sub(/^[ \t\r\n]+/, "", $0);
			printf("%d: (%s) # %s\n\tRSS: %8.2f M\n\tVSZ: %8.2f M\n",
		   	pid, uid, $0, rss/1024, vsz/1024);
		}'
}

prompt() {
	local question="$1"
	while true; do
		msg "$question"
		read -p "[y]es or [n]o (default: no) : " -r answer
		case "$answer" in
		y | Y | yes | YES | Yes)
			return 0
			;;
		n | N | no | NO | No | *[[:blank:]]* | "")
			return 1
			;;
		*)
			msg "Please answer [y]es or [n]o."
			;;
		esac
	done
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

clip() {
	# use OSC 52 for kitty, alacritty and tmux inside either of them
	error() {
		echo "no suitable copy method found" >&2
		return 1
	}
	extern() {
		if [[ $XDG_SESSION_TYPE == x11 ]]; then
			if has xsel; then
				xsel --input --clipboard --logfile /dev/null
			elif has xclip; then
				xclip -in -filter -select clipboard
			else
				error
			fi
		elif has wl-copy; then
			wl-copy --paste-once
		else
			error
		fi
	}

	if [[ -v KITTY_INSTALLATION_DIR ]]; then
		if [[ $TERM_PROGRAM == tmux ]]; then
			tmux load-buffer -w /dev/fd/0
		else
			kitty +kitten clipboard
		fi
	elif [[ -v ALACRITTY_SOCKET ]]; then
		if [[ $TERM_PROGRAM == tmux ]]; then
			tmux load-buffer -w /dev/fd/0
		else
			extern
		fi
	else
		extern
	fi
}

share() {
	local resp=$(ncat unsha.re 9999 | tee /dev/fd/2 |
		jq -r '{ expires, secret, url } | to_entries | .[] | "local " + .key + "=" + (.value | @sh)')

	if [[ -n $resp ]]; then
		eval "$resp"
		#shellcheck disable=2154
		clip <<<"$url"
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
