# shellcheck shell=bash
# ~/.profile
# you can override exported variables in host specific profiles
# in ${XDG_CONFIG_HOME}/profile/profile-${HOSTNAME}
# shellcheck disable=2155

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	printf '%d%s\n' "${EPOCHSECONDS}" ': .profile' >> "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
fi

export PROFILE_SOURCED=1

is_cmd() {
	hash "$1" &>/dev/null
}

is_in_exp () { 
	local haystack="$1[@]"
	local needle=$2
	for e in "${!haystack}"; do
		[[ $e == "$needle" ]] && return 0
	done
	return 1
}

is_in_ref () { 
	local -n haystack=$1
	local needle=$2
	for e in "${haystack[@]}"; do
		[[ $e == "$needle" ]] && return 0
	done
	return 1
}

#################################################
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
if [[ -d "${HOME}/.tmp" ]]; then
	XDG_CACHE_HOME="${HOME}/.tmp/cache"
	export TMPDIR="${HOME}/.tmp"
else
	XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
fi
export XDG_CACHE_HOME
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}

#################################################
# you can override this in host specific profiles in
# ${XDG_CONFIG_HOME}/profile/profile-${HOSTNAME}
# default: emacs > nvim > vim > vi
EDITOR='vi'

if is_cmd emacsclient; then
	EDITOR='emacsclient -qc -a emacs'
elif is_cmd nvim; then
	EDITOR='nvim'
elif is_cmd vim; then
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
path_exports=("${XDG_DATA_HOME}/../bin")
# read by PAM through the pam_env module (man 8 pam_env) - be aware that fedora
# is using a patched pam_env module which does not enable user_readenv by default
# touch ${HOME}/.pam_environment for enabling
pam_exports=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME PATH)
# environment.d (man 8 environment.d) read by systemd-environment-d-generator
# (man 8 systemd-environment-d-generator), initialized with default pam_exports
# touch ${XDG_CONFIG_HOME}/environment.d/50-profile.conf for enabling
env_exports=("${pam_exports[@]}")

#################################################
# source host specific profile
source_machine_profile() {
	local machine=${HOSTNAME:-$(</proc/sys/kernel/hostname)}
	machine=${machine,,}
	if [[ -n $machine ]]; then
		if [[ -r "${XDG_CONFIG_HOME}/profile/profile-${machine}" ]]; then
			source "${XDG_CONFIG_HOME}/profile/profile-${machine}"
		elif [[ -r "${HOME}/.profile-${machine}" ]]; then
			source "${HOME}/.profile-${machine}"
		fi
	fi
}

export_user_paths() {
	local -a rpath
	if is_cmd realpath; then
		readarray -t -d ':' apath <<< "$PATH"
		for (( i=0; i < ${#path_exports[@]}; i++ )); do
			local realp="$(realpath -qms "${path_exports[$i]}")"
			# check if already added,
			if ! is_in_ref apath "$realp"; then
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
	for var in "${pam_exports[@]}"; do
		printf -v line '%-32s DEFAULT=%s' "$var" "${!var}"
		buf+=("${line}")
	done
	local IFS=$'\n'
	printf '%s' "${buf[*]}"
}

# same for environment.d
create_envd_export() {
	local -a buf
	for var in "${env_exports[@]}"; do
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
		printf '%s\n' "$render_exp" > "${HOME}/.pam_environment"
	fi
}

write_envd_exports() {
	render_exp="$(create_envd_export)"
	if ! is_equal "${XDG_CONFIG_HOME}/environment.d/50-profile.conf" "$render_exp"; then
		printf '%s\n' "${XDG_CONFIG_HOME}/environment.d/50-profile.conf updated!" >&2
		printf '%s\n' "$render_exp" > "${XDG_CONFIG_HOME}/environment.d/50-profile.conf"
	fi
}

export_envd() {
	# unused for now, synchronizes env.d + profile variables in a 1:1 fashion
	shopt -s nullglob
	local -r envd="${XDG_CONFIG_HOME}/environment.d"
	set -a
	if [[ -d $fragment ]]; then
		for fragment in "${envd}"/*.conf
		do
			source "$fragment"
		done
	fi
	set +a
}

# load host specific profile
source_machine_profile
# export canonicalized 'path_exports' entries after sourcing host specific profile
export_user_paths

# has to be manually called by the user
generate-env() {
	write_pamd_exports
	write_envd_exports
}

# vim: ft=bash ts=4 sw=4 noet
