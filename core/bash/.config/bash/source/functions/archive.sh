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

mirror-stream() {
	tar \
		--numeric-owner \
		--acls \
		--xattrs \
		--selinux \
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

fcrypt() {
	gpg \
		--no-option \
		--symmetric \
		--yes \
		--compress-algo none \
		--s2k-cipher-algo AES256 \
		--s2k-digest-algo SHA512 \
		--s2k-mode 3 \
		--s2k-count 65011712 \
		-- "$@"
}

fdecrypt() {
	gpg \
		--no-option \
		--decrypt \
		--yes \
		--output "$(basename "$@" .gpg)" \
		-- "$@"
}

create-fec() {
	if ! has par2create; then
		msg 'par2create not found.'
		return 1
	fi
	par2create -qq -r1 -n1 "$@"
}

# create lean archive preserving filename, permissions and data only
mkarchive() {
	local -i usefec=0
	if [[ $1 == "--fec" ]]; then
		usefec=1
		shift
	fi
	local -r src=$1

	if [[ ! -r $1 ]]; then
		msg 'Cannot read input.'
		return 1
	fi

	# check for destination
	if (($# == 2)); then
		local -r dest=$(readlink -qne "$2")
		if [[ -z $dest ]]; then
			msg 'Target directory must exist.'
			return 1
		fi
	fi

	local -r base=$(basename "$1")
	local archive
	printf -v archive '%s%s' "${dest:+$dest/}" "$base"

	if [[ -d $src ]]; then
		printf -v out '%s.tar.zst' "$archive"
		docmd="archive-stream $src"
	else
		printf -v out '%s.zst' "$archive"
		docmd="cat $src"
	fi

	#shellcheck disable=SC2030
	$docmd | compress-stream |
		if [[ ! -v NOENC ]]; then
			encrypt-stream >"${out}.gpg"
		else
			cat >"$out"
		fi

	if ((usefec == 1)); then
		create-fec "$out"
	fi
}

# create archive preserving most of the metadata
mkbackup() {
	local -i usefec=0
	if [[ $1 == "--fec" ]]; then
		usefec=1
		shift
	fi
	local -r src=$1

	if [[ ! -r $1 ]]; then
		msg 'Cannot read input.'
		return 1
	fi

	# check for destination
	if (($# == 2)); then
		local -r dest=$(readlink -qne "$2")
		if [[ -z $dest ]]; then
			msg 'Target directory must exist.'
			return 1
		fi
	fi

	local -r base=$(basename "$1")
	printf -v out '%s%s.tar.zst' "${dest:+$dest/}" "$base"
	#shellcheck disable=SC2031
	mirror-stream "$src" | compress-stream |
		if [[ ! -v NOENC ]]; then
			encrypt-stream >"${out}.gpg"
		else
			cat >"$out"
		fi

	if ((usefec == 1)); then
		create-fec "$out"
	fi
}

canonicalize-sanitize-path-string() {
	local -r path=$(readlink -qnm "$1")
	printf '%s' "$path" | tr -d '\n' | sed -E 's/\//-/g;s/^-|-$//g;s/\./dot-/g;s/\s/_/g'
}

if has mksquashfs; then
	mkimg() {
		trap 'command rm -f -- "${dst}/acl.log"' RETURN

		if [[ $1 == '--fast' ]]; then
			local fast='lz4'
			shift
		fi

		if (($# < 2)); then
			set "$1" '.'
		fi

		local -r src=$(readlink -qne "$1")
		local -r dst=$(readlink -qne "$2")
		shift 2

		local san=$(canonicalize-sanitize-path-string "$src")

		if [[ -z $src ]]; then
			msg 'Source directory must exist.'
			return 1
		fi

		if [[ -z $dst ]]; then
			msg 'Target directory must exist.'
			return 1
		fi

		if [[ -z $san ]]; then
			san='root'
		fi
		local out
		printf -v out '%s/%s-%u.sfs' "$dst" "$san" "$EPOCHSECONDS"

		# embed POSIX ACLs log inside the image (restore with `setfacl --restore=acl.log`)
		if has getfacl; then
			getfacl -Rs "$src" > "${dst}/acl.log"
		fi

		mksquashfs "$src" "${dst}/acl.log" "$out" \
			-not-reproducible \
			-noappend \
			-xattrs \
			-comp "${fast:-zstd}" \
			-keep-as-directory \
			-progress \
			-wildcards \
			-e "${@:-}"
	}
fi