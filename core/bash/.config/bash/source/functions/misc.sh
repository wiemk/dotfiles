# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash
# shellcheck disable=2155,1090

init_debug

if has secret-tool; then
	get-secret() {
		local -r kv=$1
		readarray -td : arr < <(printf "%s\0" "$kv")
		secret-tool lookup "${arr[0]}" "${arr[1]}"
	}
else
	# shim to avoid further checks
	get-secret() {
		printf '%s' "$*"
	}
fi

if has xfreerdp; then
	rdp() {
		local store=$3
		store=$(get-secret "rdp:${store}")
		if [[ -z $store ]]; then
			store=$3
		fi

		sc-run xfreerdp \
			/network:auto /rfx /dvc:echo /w:1600 /h:900 /dvc:echo /geometry /cert:ignore \
			+compression +async-channels +async-input -encryption -grab-keyboard \
			/v:"${1}" /u:"${2}" /p:"${store}" "${@:4}"
	}
fi

if has scrcpy; then
	scc() {
		sc-run scrcpy --max-size 1600 --bit-rate 12M --max-fps 60 "$@"
	}
fi

if has xprop && has xdotool; then
	xnobar() {
		local -r window=$(xdotool getactivewindow)
		xprop -id "$window" -f _MOTIF_WM_HINTS 32c \
			-set _MOTIF_WM_HINTS '0x2, 0x0, 0x0, 0x0, 0x0'

	}
fi

if has htop; then
	htop() {
		command htop --drop-capabilities=strict 2>/dev/null || command htop
	}
fi

if has mediainfo; then
	minfo() {
		mediainfo --inform_version=0 --Output=JSON "$@" \
			| jq --raw-output --slurp 'map({FPS: .media.track[0].FrameRate,
					AudioTracks: .media.track[0].AudioCount,
					Format: .media.track[1].Format,
					Profile: .media.track[1].Format_Profile,
					BitDepth: .media.track[1].BitDepth,
					ChromaSub: .media.track[1].ChromaSubsampling})'
	}
fi

if has navi; then
	naviq() {
		navi --query "$1"
	}
fi

if has mullvad; then
	alias vpn='mullvad'
	alias vpnf='vpn-latency'

	vpn-latency() {
		local -r status=$(mullvad status)
		if [[ $status != 'Disconnected' ]]; then
			mullvad disconnect
			sleep 2s
			if ip --brief link show wg-mullvad up type wireguard &>/dev/null; then
				sudo ip link del wg-mullvad
			fi
		fi

		local country
		if (($# < 1)); then
			country=de
		else
			country=$1
		fi

		local -r server=$(mullvad-best-server -country "$country" -provider=31173 -warmup)
		printf -v host '%s-wireguard' "$server"

		mullvad relay set hostname "$host"
		mullvad connect
	}
fi
