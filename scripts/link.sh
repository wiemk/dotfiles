#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034

set -eo pipefail

shopt -s nullglob extglob

base=$(dirname "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

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
	for bin in "${base}"/bin/*; do
		if [[ -d $bin ]]; then
			local source target
			printf -v source '%s/%s' "$bin" "${bin##*/}"
			printf -v target '%s/.local/bin/%s' "$HOME" "${bin##*/}"
			printf '%-80s -> %s\n' "$source" "$target"
			targets[$source]=$target
		fi
	done

	for lib in "${base}"/lib/*; do
		if [[ -f $lib ]]; then
			local source=$lib
			local target
			printf -v target '%s/%s' "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/lib" "${lib##*/}"
			printf '%-80s -> %s\n' "$source" "$target"
			targets[$source]=$target
		fi
	done
}

build_list
if prompt "Link?"; then
	mkdir -p ~/.local/bin "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/lib"
	for source in "${!targets[@]}"; do
		command ln -v --symbolic --relative --no-target-directory --force "$source" "${targets[$source]}"
	done
fi

# vi: set ft=sh ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=manual: