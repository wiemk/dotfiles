# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash
# shellcheck disable=2155,1090

init_debug

if ! has_all tar gpg zstd; then
	return
fi

archive-stream() {
	tar \
		--no-acls \
		--no-selinux \
		--no-xattrs \
		--sparse \
		--create \
		-- "$@" 2>/dev/null
}

compress-stream() {
	local -r threads=$(($(nproc) / 2))
	zstd -T"$threads" --long -9 -C --
}

encrypt-stream() {
	gpg \
		--no-option \
		--symmetric \
		--compress-algo none \
		--s2k-cipher-algo AES256 \
		--s2k-digest-algo SHA512 \
		--s2k-mode 3 \
		--s2k-count 65011712 \
		-- -
}

create-fec() {
	if ! has par2create; then
		msg "par2create not found."
		return 1
	fi
	par2create -qq -r1 -n1 "$@"
}

mkarchive() {
	local -i usefec=0
	if [[ $1 == "--fec" ]]; then
		usefec=1
		shift
	fi
	local -r src=$1

	if ! [[ -r $1 ]]; then
		msg 'Cannot read input.'
		return 1
	fi

	# check for destination
	if (($# == 2)); then
		local -r dest=$(readlink -qe "$2")
		if [[ -z $dest ]]; then
			msg "Target directory must exist."
			return 1
		fi
	fi

	local -r base=$(basename "$1")
	local archive
	printf -v archive '%s%s.tar.zst.gpg' "${dest:+$dest/}" "$base"

	archive-stream "$src" | compress-stream | encrypt-stream >"$archive"

	if ((usefec == 1)); then
		create-fec "$archive"
	fi
}