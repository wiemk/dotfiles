#!/usr/bin/false
# shellcheck shell=bash
# shellcheck disable=2155,1090


has() {
	if hash "$1" &>/dev/null; then
		return 0
	fi
	return 1
}

msg() {
	echo >&2 -e "${1-}"
}

die() {
	local msg=$1
	local code=${2-1}
	msg "$msg"
	exit "$code"
}

prompt() {
	msg() {
		local text=$1
		local div_width="120"
		printf "%${div_width}s\n" ' ' | tr ' ' -
		printf "%s\n" "$text"
	}
	local question=$1
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

# vi: set ft=sh ts=4 sw=0 sts=-1 sr noet nosi tw=80 fdm=manual: