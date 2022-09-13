# vi: set ft=sh ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=manual:
# shellcheck shell=bash
# shellcheck disable=2155,1090

init_debug

if ! has_all tar zstd; then
	return
fi

invoke-cmd() {
	if ((SHOW_CMD)); then
		echo -ne "$*" >&2
	else
		eval "$*"
	fi
}

fcrypt() {
	invoke-cmd gpg \
		--no-option \
		--symmetric \
		--yes \
		--compress-algo none \
		--s2k-cipher-algo AES256 \
		--s2k-digest-algo SHA512 \
		--s2k-mode 3 \
		--s2k-count 65011712 \
		-- "$*"
}

fdecrypt() {
	invoke-cmd gpg \
		--no-option \
		--decrypt \
		--yes \
		--output "$(basename "$1" .gpg)" \
		-- "$*"
}

archive-stream() {
	invoke-cmd tar \
		--no-acls \
		--no-selinux \
		--no-xattrs \
		--sparse \
		--create \
		-- "$*"
}

mirror-stream() {
	invoke-cmd tar \
		--numeric-owner \
		--acls \
		--xattrs \
		--selinux \
		--sparse \
		--create \
		-- "$*"
}

encrypt-stream-gpg() {
	invoke-cmd gpg \
		--no-option \
		--symmetric \
		--compress-algo none \
		--s2k-cipher-algo AES256 \
		--s2k-digest-algo SHA512 \
		--s2k-mode 3 \
		--s2k-count 65011712 \
		-- -
}

encrypt-stream-pass() {
	if has_emit pass; then
		invoke-cmd gpg \
			--no-option \
			--pinentry-mode loopback \
			--passphrase-file "<(pass archive)" \
			--symmetric \
			--compress-algo none \
			--s2k-cipher-algo AES256 \
			--s2k-digest-algo SHA512 \
			--s2k-mode 3 \
			--s2k-count 65011712 \
			-- -
	else
		return 1
	fi
}

encrypt-stream-age() {
	invoke-cmd age \
		-p \
		-- -
}

compress-stream() {
	local -a flag=(--long -9)
	while :; do
		case ${1-} in
		-f | --fast) flag=(-3) ;;
		-u | --ultra) flag=(--long -19) ;;
		*)
			break
			;;
		esac
		shift
	done

	local -r threads=$(($(nproc) / 2))
	invoke-cmd zstd -T"$threads" "${flag[@]}" -C --
}

create-fec() {
	has_emit par2create || return 1
	invoke-cmd par2create -qq -r1 -n1 "$@"
}

dearc() {
	if [[ -f "$1" && $(file -b "$1") == PGP* ]]; then
		command gpg --decrypt "$1" | zstd -d -- | tar -vx --
		return
	else
		local ec=$(basename "$1" .age)
		if [[ $1 != "$ec" ]]; then
			command age --decrypt "$1" | zstd -d -- | tar -vx --
			return
		fi
	fi
	msg 'Not a valid arc file.'
	return 1
}

# create lean archive preserving filename, permissions and data only
arc() {
	local flag_age=0 \
		flag_bare=0 \
		flag_enc=1 \
		flag_fec=0 \
		flag_pass=0 \
		flag_meta=0 \
		flag_dry=0 \
		flag_root=0 \
		flag_store=

	while :; do
		case ${1-} in
		-h | --help)
			cat <<-'HELP'
				Flags:
					-a|--age     : use age instead of gpg
					-b|--bare    : no tar
					-d|--dry-run : dry-run, shows execution pipeline
					-f|--fec     : forward error correction
					-m|--meta    : embed all supported metadata
					-n|--noenc   : do not encrpyt
					-p|--pass    : use pass tool entry 'archive' as PSK
					-r|--root    : run with sudo
					-s|--store   : faster compression

				Pos:
					<src> [<dst/>]
			HELP
			return 0
			;;
		-a | --age)
			{ has_emit age && flag_age=1; } ||
				return 1
			;;
		-b | --bare) flag_bare=1 ;;
		-d | --dry-run) flag_dry=1 ;;
		-f | --fec) flag_fec=1 ;;
		-m | --meta) flag_meta=1 ;;
		-n | --noenc) flag_enc=0 ;;
		-p | --pass)
			{ has_emit pass && flag_pass=1; } ||
				return 1
			;;
		-r | --root) flag_root=1 ;;
		-s | --store) flag_store='--fast' ;;
		*)
			break
			;;
		esac
		shift
	done

	local -r src=$1
	if [[ ! -r $1 ]]; then
		msg 'Cannot read input.'
		return 1
	fi

	# check for destination
	if (($# == 2)); then
		local -r dest=$(readlink -qne -- "$2")
		if [[ -z $dest ]]; then
			msg 'Target directory must exist.'
			return 1
		fi
	fi

	local -r base=$(basename "$1")
	local out

	if ((flag_bare)) && [[ ! -d "$src" ]]; then
		printf -v out '%s%s.zst' "${dest:+$dest/}" "$base"
	else
		printf -v out '%s%s.tar.zst' "${dest:+$dest/}" "$base"
	fi

	if ((flag_enc)); then
		if ! has_emit gpg; then
			return 1
		fi
		if ((flag_age)); then
			printf -v out '%s.age' "$out"
		else
			printf -v out '%s.gpg' "$out"
		fi
	fi

	local cmd=$(
		{
			#shellcheck disable=SC2030,SC2031
			export SHOW_CMD=1
			if ((!flag_bare)); then
				if ((flag_meta)); then
					mirror-stream "'$src'"
				else
					archive-stream "'$src'"
				fi
				printf ' | \\\n' >&2
			fi
			compress-stream "${flag_store:-}"

			if ((flag_enc)); then
				printf ' | \\\n' >&2
				if ((flag_age)); then
					encrypt-stream-age >"'$out'"
				else
					if ((flag_pass)); then
						encrypt-stream-pass
					else
						encrypt-stream-gpg
					fi
				fi
			fi
			printf ' >%s' "'$out'" >&2

			if ((flag_fec)); then
				printf ' && \\\n' >&2
				create-fec "'$out'"
			fi
		} 2>&1
	)

	if ((flag_root)); then
		# prepend tar with sudo for read permissions
		printf -v cmd 'command sudo -- %s' "$cmd"
	fi

	if ((flag_dry)); then
		msg "$cmd"
	else
		invoke-cmd "$cmd"
	fi
}

if has mksquashfs; then
	mksfs() {
		trap 'command rm -f -- "${dst}/acl.log"' RETURN

		local flag_dry=0 \
			flag_root=0 \
			opt_fast=

		while :; do
			case ${1-} in
			-h | --help)
				cat <<-'HELP'

					Flags:
						-d|--dry-run : dry-run, shows execution pipeline
						-s|--store   : lz4 compression
						-r|--root    : run with sudo

					Pos:
						<src> [<dst/>]

				HELP
				return 0
				;;
			-d | --dry-run) flag_dry=1 ;;
			-s | --store) opt_fast=lz4 ;;
			-r | --root) flag_root=1 ;;
			*)
				break
				;;
			esac
			shift
		done

		if (($# < 2)); then
			set -- "$1" '.'
		fi

		local -r src=$(readlink -qne -- "$1")
		local -r dst=$(readlink -qne -- "$2")
		shift 2

		local san=$(printf '%s' "$src" | tr -d '\n' | sed -E 's/\//-/g;s/^-|-$//g;s/\./dot-/g;s/\s/_/g')

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

		local cmd=$(
			{
				#shellcheck disable=SC2030,SC2031
				export SHOW_CMD=1
				if has getfacl; then
					invoke-cmd getfacl -Rs "'$src'"
					printf '>%s' "'${dst}/acl.log'"
					printf ' &&\n' >&2
				fi
				invoke-cmd mksquashfs "'$src'" "'${dst}/acl.log'" "'$out'" -not-reproducible -noappend -xattrs -comp "${opt_fast:-zstd}" -keep-as-directory -progress -wildcards "${@:-}"
			} 2>&1
		)

		if ((flag_root)); then
			printf -v cmd "command sudo -- bash -c '%s &&\nchown --quiet --preserve-root %u:%u %s'" "$cmd" "$(id -u)" "$(id -g)" "'$out'"
		fi

		if ((flag_dry)); then
			msg "$cmd"
		else
			invoke-cmd "$cmd"
		fi
	}
fi