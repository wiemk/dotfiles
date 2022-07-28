# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

if has mullvad; then
	vpn() {
		local country
		if (($# < 1)); then
			country=de
		else
			country=$1
		fi
		printf -v host '%s-wireguard' "$(mullvad-best-server -country "$country" -provider=31173 -warmup)"
		mullvad relay set hostname "$host"

		if ip --brief link show wg-mullvad up type wireguard &>/dev/null; then
			sudo ip link del wg-mullvad
		fi

		mullvad connect
	}
fi