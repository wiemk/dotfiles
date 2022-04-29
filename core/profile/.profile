# vim: ft=sh ts=4 sw=4 noet
# shellcheck shell=bash
# shellcheck disable=2155,1090
#
# Override exported variables in host specific profiles
# in ${XDG_CONFIG_HOME}/profile/${HOSTNAME}.conf

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/bash/_debug" ]]; then
	on_debug() {
		local -r script=$(readlink -e -- "${BASH_SOURCE[1]}") || return
		printf '%d%s\n' "${EPOCHSECONDS}" ": ${script}" >>"${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
	}
else
	on_debug() { :; }
fi

on_debug

export PROFILE_SOURCED=1

has() {
	if hash "${1}" &>/dev/null; then
		return 0
	fi
	return 1
}

contains() {
	local -n arr=$1
	local n=$2
	for e in "${arr[@]}"; do
		[[ $e == "$n" ]] && return 0
	done
	return 1
}

#################################################

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
XDG_STATE_HOME=${XDG_STATE_HOME:-${HOME}/.local/state}

export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

#################################################
# you can override this in host specific profiles in
# ${XDG_CONFIG_HOME}/profile/profile-${HOSTNAME}
# default: emacs > nvim > vim > vi
EDITOR='vi'

if has emacsclient; then
	EDITOR='emacsclient -qc -a emacs'
elif has nvim; then
	EDITOR='nvim'
elif has vim; then
	EDITOR='vim'
fi
export EDITOR

export SUDO_EDITOR='vi'
export ALTERNATE_EDITOR='vi'
export VISUAL="${EDITOR}"
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE="${XDG_CACHE_HOME}/lesshist"
export SYSTEMD_PAGER='cat'

#################################################
# define additional PATH folders here
PATH_EXPORTS=("${XDG_DATA_HOME}/../bin")
# read by PAM through the pam_env module (man 8 pam_env) - be aware that fedora
# is using a patched pam_env module which does not enable user_readenv by default
# touch ${HOME}/.pam_environment for enabling
PAM_EXPORTS=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME PATH)
# environment.d (man 8 environment.d) read by systemd-environment-d-generator
# (man 8 systemd-environment-d-generator), initialized with default PAM_EXPORTS
# touch ${XDG_CONFIG_HOME}/environment.d/50-profile.conf for enabling
ENV_EXPORTS=("${PAM_EXPORTS[@]}")

#################################################
# source host specific profile
source_machine_profile() {
	local machine=$(</etc/machine-id)
	if [[ -n $machine ]]; then
		if [[ -r "${XDG_CONFIG_HOME}/profile/${machine}.conf" ]]; then
			source "${XDG_CONFIG_HOME}/profile/${machine}.conf"
		elif [[ -r "${HOME}/.profile-${machine}.conf" ]]; then
			source "${HOME}/.profile-${machine}.conf"
		fi
	fi
}
source_host_profile() {
	local host=${HOSTNAME:-$(</proc/sys/kernel/hostname)}
	host=${host,,}
	if [[ -n $host ]]; then
		if [[ -r "${XDG_CONFIG_HOME}/profile/${host}.conf" ]]; then
			source "${XDG_CONFIG_HOME}/profile/${host}.conf"
		elif [[ -r "${HOME}/.profile-${host}.conf" ]]; then
			source "${HOME}/.profile-${host}.conf"
		fi
	fi
}

export_user_paths() {
	local -a rpath
	if has realpath; then
		# shellcheck disable=SC2034
		readarray -t -d ':' apath <<<"$PATH"
		for ((i = 0; i < ${#PATH_EXPORTS[@]}; i++)); do
			local realp="$(realpath -qms "${PATH_EXPORTS[$i]}")"
			# check if already added,
			if ! contains apath "$realp"; then
				rpath+=("$realp")
			fi
		done
	fi
	local path=("${rpath[@]}" "$PATH")
	printf -v spath '%s:' "${path[@]%/}"
	PATH="${spath:0:-1}"
	export PATH
}

# export for pam_env and avoid unnecessary writes
create_pamd_export() {
	local -a buf
	for var in "${PAM_EXPORTS[@]}"; do
		printf -v line '%-32s DEFAULT=%s' "$var" "${!var}"
		buf+=("${line}")
	done
	local IFS=$'\n'
	printf '%s' "${buf[*]}"
}

# same for environment.d
create_envd_export() {
	local -a buf
	for var in "${ENV_EXPORTS[@]}"; do
		printf -v line '%s=%s' "$var" "${!var}"
		buf+=("${line}")
	done
	local IFS=$'\n'
	printf '%s' "${buf[*]}"
}

is_equal() {
	local file="$1" nbuf="$2"
	if [[ -r "${file}" ]]; then
		command cmp -s "$file" <(printf '%s\n' "${nbuf}")
	fi
}

write_pamd_exports() {
	render_exp="$(create_pamd_export)"
	if ! is_equal "${HOME}/.pam_environment" "$render_exp"; then
		printf '%s\n' "${HOME}/.pam_environment updated!" >&2
		printf '%s\n' "$render_exp" >"${HOME}/.pam_environment"
	fi
}

write_envd_exports() {
	render_exp="$(create_envd_export)"
	if ! is_equal "${XDG_CONFIG_HOME}/environment.d/50-profile.conf" "$render_exp"; then
		printf '%s\n' "${XDG_CONFIG_HOME}/environment.d/50-profile.conf updated!" >&2
		printf '%s\n' "$render_exp" >"${XDG_CONFIG_HOME}/environment.d/50-profile.conf"
	fi
}

export_envd() {
	# unused for now, synchronizes env.d + profile variables in a 1:1 fashion
	shopt -s nullglob
	local -r envd="${XDG_CONFIG_HOME}/environment.d"
	set -a
	if [[ -d $fragment ]]; then
		for fragment in "${envd}"/*.conf; do
			source "$fragment"
		done
	fi
	set +a
}

# load machine specific profile
source_machine_profile

# load host specific profile
source_host_profile

# export canonicalized 'PATH_EXPORTS' entries after sourcing host specific profile
export_user_paths

# has to be manually called by the user
generate-env() {
	write_pamd_exports
	write_envd_exports
}
