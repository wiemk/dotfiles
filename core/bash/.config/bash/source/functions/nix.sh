# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

if ! has nix-env; then
	return
fi

nix-lean() {
	nix profile wipe-history
	nix store gc
	nix store optimise
}

nix-lean-legacy() {
	nix-env --delete-generations old
	nix-store --gc
	nix-store --optimise
}
