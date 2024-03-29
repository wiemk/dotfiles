# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

# check if host is a fedora system
# and don't clobber namespace
# no -> return early
(
	if [[ -e /usr/lib/os-release ]]; then
		source /usr/lib/os-release
	else
		source /etc/os-release
	fi
	if [[ $ID == fedora ]]; then
		exit 0
	fi
	exit 1
) || return

if has koji; then
	# transform space delimited input to null bytes
	koji-check() {
		printf '%s\0' "$@" \
			| xargs -P8 -L1 -0 koji list-builds --state=COMPLETE --after="$(env LC_ALL=C date -d -'2 days')" --package
	}
	koji-arch() {
		printf '%s\0' "$@" \
			| xargs -P8 -L1 -0 koji download-build --arch=x86_64
	}
	koji-noarch() {
		printf '%s\0' "$@" \
			| xargs -P8 -L1 -0 koji download-build --arch=noarch
	}
fi

if has jq; then
	kernels() {
		curl -Ls https://kernel.org/releases.json | jq -r '.releases[] | select(.moniker != "longterm") | .moniker + ":" + .version'
	}
fi

dnf-extra() {
	# list packages no loger available in enabled repos
	sudo dnf list extras
}

dnf-retired() {
	# list explicitly retired packages from last fedora version
	local -r pkg=remove-retired-packages
	if ! has $pkg; then
		sudo dnf install $pkg
	fi
	$pkg
}

dnf-unsatisfied() {
	# list potentially broken dependencies
	sudo dnf repoquery --unsatisfied
}

dnf-reason() {
	# list install reason for a package
	sudo dnf -qC repoquery --installed --qf='%{name}-%{evr}.%{arch} (%{reason})' "${1}" | grep --color=never -oP '(?<=\()[\w-]+(?=\))'
}

dnf-group() {
	# member of any group?
	sudo dnf -qC repoquery --groupmember "$1"
}

dnf-needed() {
	# is it needed by anything?
	sudo dnf -qC repoquery --unneeded "$1"
}

dnf-history() {
	# install history for a package
	sudo dnf -qC history "$1"
}

rpm-weak() {
	# weak dependencies of a package
	msg "=== Supplements ==="
	rpm -q --whatsupplements "$1"
	msg "=== Recommends ==="
	rpm -q --whatrecommends "$1"
}

dnf-info() {
	# collect package specific information from above
	local -r pkg=$1
	if ! rpm -q "$pkg" &>/dev/null; then
		msg "package not installed"
		return 1
	fi
	# prime sudo
	sudo -v
	msg "=== Install reason ==="
	dnf-reason "$pkg"
	msg "=== Member of groups ==="
	dnf-group "$pkg"
	msg "=== Weak dependencies ==="
	rpm-weak "$pkg"
	msg "=== Marked for autoremove ==="
	if [[ $(dnf-needed "$pkg" | wc -l) -gt 0 ]]; then
		msg "YES"
	fi
	msg "=== History ==="
	dnf-history "$pkg"
	msg "\n=== Description ===\n"
	rpm -qi "$pkg"
}

getseerror() {
	sudo ausearch -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR -ts recent
}
