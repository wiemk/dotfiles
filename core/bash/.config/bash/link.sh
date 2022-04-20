#!/usr/bin/env bash
# vi:set ft=bash ts=4 sw=4 noet noai:
# shellcheck disable=SC2034

# set up basic install

set -eo pipefail

declare -A FUNC_PRIO=([alias]=50 [fedora]=50 [editor]=51 [tmux]=50 [util]=30)
declare -A PLUGIN_PRIO=([fzf]=10 [prompt]=10 [vivid]=10 [zoxide]=10)

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

link FUNC_PRIO functions
link PLUGIN_PRIO plugins
