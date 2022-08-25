#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034

# Link a default set of provided files into bash environment

set -eo pipefail

declare -A FUNC=(
	[alias]=50
	[archive]=90
	[editor]=51
	[fedora]=50
	[info]=90
	[misc]=90
	[systemd]=20
	[tmux]=50
	[util]=30
)
declare -A PLUGIN=(
	[fzf]=10
	[gnupg]=10
	[prompt]=10
	[vivid]=10
	[zoxide]=10
)

link() {
	local -n prio=$1
	local -r folder=$2
	for fragment in "${!prio[@]}"; do
		local src dst
		printf -v src "source/%s/%s.sh" "$folder" "$fragment"
		printf -v dst "source.d/%s-%s.sh" "${prio[$fragment]}" "$fragment"
		printf "# Linking %s to %s\n" "$src" "$dst" >&2
		command ln -v --symbolic --relative --no-target-directory --force "$src" "$dst"
	done
}

pushd "$(dirname "${BASH_SOURCE:0}")" &>/dev/null
trap 'popd &>/dev/null' EXIT

link FUNC functions
link PLUGIN plugins

# vi: set ft=sh ts=4 sw=0 sts=-1 sr noet nosi tw=80 fdm=manual: