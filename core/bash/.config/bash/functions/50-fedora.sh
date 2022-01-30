# vi:set ft=bash ts=4 sw=4 noet noai:
on_debug

if has koji; then
	chkpkg() {
		echo -n "$*" \
			| tr ' ' '\0' \
			| xargs -P8 -L1 -0 koji list-builds --state=COMPLETE --after="$(env LC_ALL=C date -d -'2 days')" --package
		}
fi

dnf-reason() {
	sudo dnf -qC repoquery --installed --qf='%{name}-%{evr}.%{arch} (%{reason})' "${1}" | grep --color=never -oP '\(.*\)'
}

dnf-group() {
	sudo dnf -qC repoquery --groupmember "${1}"
}

dnf-history() {
	sudo dnf -qC history "${1}"
}

rpm-weakdeps() {
	rpm -q --whatsupplements "${1}"
}

pkginfo() {
	local -r pkg=$1
	sudo -v
	echo "=== Install reason ==="
	dnf-reason "$pkg"
	echo "=== Member of groups ==="
	dnf-group "$pkg"
	echo "=== Weak dependencies ==="
	rpm-weakdeps "$pkg"
	printf "\n=== History ===\n"
	dnf-history "$pkg"
	printf "\n=== Description ===\n"
	rpm -qi "$pkg"
}
