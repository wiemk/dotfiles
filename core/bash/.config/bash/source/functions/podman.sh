# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash
# shellcheck disable=2155,1090

init_debug

podman-volume-rename() {
	if (($# < 2)); then
		msg 'podman-rename-volume <old> <new>'
		return 1
	fi

	local -r old=$1
	local -r new=$2

	if ! podman volume exists "$old"; then
		msg 'Coult not find source volume' "$old"
		return 1
	fi

	if ! podman volume create "$new"; then
		msg 'Could not create new volume.'
		return 1
	fi

	if podman run \
		--interactive \
		--rm \
		--tty \
		--volume="$old":/from:ro \
		--volume="$new":/to \
		--security-opt=label=disable \
		docker.io/library/alpine:3 \
		/bin/cp -av /from/. /to; then
		podman volume rm "$old"
	else
		msg 'Copy operation failed, old volume unaltered.'
		return 1
	fi
}