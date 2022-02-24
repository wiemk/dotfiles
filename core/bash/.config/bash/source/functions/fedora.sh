# vi:set ft=bash ts=4 sw=4 noet noai:

on_debug

# check if host is a fedora system
# no -> return early
(
	source /etc/os-release
	if [[ $ID == fedora ]]; then
		exit 1
	else
		exit 0
	fi
) && return

if has koji; then
	chkpkg() {
		echo -n "$*" |
			tr ' ' '\0' |
			xargs -P8 -L1 -0 koji list-builds --state=COMPLETE --after="$(env LC_ALL=C date -d -'2 days')" --package
	}
fi

dnf-reason() {
	sudo dnf -qC repoquery --installed --qf='%{name}-%{evr}.%{arch} (%{reason})' "${1}" | grep --color=never -oP '(?<=\()[\w-]+(?=\))'
}

dnf-group() {
	sudo dnf -qC repoquery --groupmember "${1}"
}

dnf-needed() {
	sudo dnf -qC repoquery --unneeded "${1}"
}

dnf-history() {
	sudo dnf -qC history "${1}"
}

rpm-weakdeps() {
	rpm -q --whatsupplements "${1}"
}

pkginfo() {
	local -r pkg=$1
	if ! rpm -q "$pkg" &>/dev/null; then
		echo "package not installed"
		return 1
	fi
	sudo -v
	echo "=== Install reason ==="
	dnf-reason "$pkg"
	echo "=== Member of groups ==="
	dnf-group "$pkg"
	echo "=== Weak dependencies ==="
	rpm-weakdeps "$pkg"
	echo "=== Marked for autoremove ==="
	if [[ $(dnf-needed "$pkg" | wc -l) -gt 0 ]]; then
		echo "YES"
	fi
	printf "=== History ===\n"
	dnf-history "$pkg"
	printf "\n=== Description ===\n"
	rpm -qi "$pkg"
}
