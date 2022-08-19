#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034

set -eo pipefail

base=$(dirname "$(readlink -f "${BASH_SOURCE[0]:-$0}")")

prompt() {
	msg() {
		local text=$1
		local div_width=120
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

declare -A targets

build_list() {
	shopt -s nullglob
	for i in "${base}"/*; do
		if [[ -d "$i" ]]; then
			local source target
			printf -v source '%s/.local/bin/%s' "$i" "${i##*/}"
			printf -v target '%s/.local/bin/%s' "$HOME" "${i##*/}"
			printf '%-80s -> %s\n' "$source" "$target"
			targets[$source]=$target
		fi
	done
}

link_shared() {
	local target=${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/lib
	mkdir -p "$target"
	local source
	printf -v source '%s/../share/lib/.local/share/dotfiles/lib/lib.sh' "$base"
	source=$(readlink -e "$source")
	if [[ -n $source ]]; then
		command ln -v --symbolic --relative --no-target-directory --force "$source" "${target}/lib.sh"
	else
		return 1
	fi
}

build_list
if prompt "Link?"; then
	if ! link_shared; then
		msg "Something went wrong with the shared library file path. Please link lib.sh to ~/.local/share/dotfiles/lib/lib.sh manually."
	fi

	mkdir -p ~/.local/bin
	for source in "${!targets[@]}"; do
		command ln -v --symbolic --relative --no-target-directory --force "$source" "${targets[$source]}"
	done
fi
# vi: set ft=sh ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=manual: