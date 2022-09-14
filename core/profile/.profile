# vim: ft=sh ts=4 sw=4 noet
# shellcheck shell=bash
# shellcheck disable=1090,1091,2155

# ONLY COMPATIBLE WITH BASH 5 OR LATER

# DEBUG
if [[ -e ${XDG_CONFIG_HOME}/bash/_debug ]]; then
	init_debug() {
		local -r script=$(readlink -e -- "${BASH_SOURCE[1]}") || return
		printf '%d%s\n' "${EPOCHSECONDS}" ": ${script}" >>"${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/profile_dbg.log"
	}
else
	init_debug() { :; }
fi

init_debug

export PROFILE_SOURCED=1

if hash &>/dev/null; then
	has() {
		hash "$1" &>/dev/null
	}
else
	# hashing disabled (NixOS)
	has() {
		command -v "$1" &>/dev/null
	}
fi

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
XDG_BIN_HOME=${XDG_BIN_HOME:-$(readlink -qf "${XDG_DATA_HOME}/../bin")}

export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_BIN_HOME

# define additional PATH folders here
PATH_EXPORTS=("${XDG_BIN_HOME}")

# transform PATH_EXPORTS array into PATH environment variable
export_user_paths() {
	local -a rpath
	# shellcheck disable=SC2034
	readarray -t -d ':' apath <<<"$PATH"
	for ((i = 0; i < ${#PATH_EXPORTS[@]}; i++)); do
		local realp=$(readlink -qms -- "${PATH_EXPORTS[$i]}")
		# don't add twice
		if ! contains apath "$realp"; then
			rpath+=("$realp")
		fi
	done
	local path=("${rpath[@]}" "$PATH")
	printf -v spath '%s:' "${path[@]%/}"
	PATH=${spath:0:-1}
	export PATH
}

# make new PATH available in machine profiles
export_user_paths

#################################################
# you can override this in host specific profiles in
# ${XDG_CONFIG_HOME}/profile/profile-${HOSTNAME}
# default: nvim > vim > vi
EDITOR='vi'
if has nvim; then
	EDITOR='nvim'
elif has vim; then
	EDITOR='vim'
fi
export EDITOR

# EDITOR may be overriden later and only be available in user PATH so set SUDO_EDITOR now
export SUDO_EDITOR=$EDITOR
export ALTERNATE_EDITOR='vi'
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE=${XDG_CACHE_HOME}/lesshist
export SYSTEMD_PAGER='cat'

#################################################
# read by PAM through the pam_env module (man 8 pam_env) - be aware that fedora
# is using a patched pam_env module which does not enable user_readenv by default
# touch ${HOME}/.pam_environment for enabling
PAM_EXPORTS=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME PATH)
# environment.d (man 8 environment.d) read by systemd-environment-d-generator
# (man 8 systemd-environment-d-generator), initialized with default PAM_EXPORTS
# touch ${XDG_CONFIG_HOME}/environment.d/50-profile.conf for enabling
ENV_EXPORTS=("${PAM_EXPORTS[@]}")

# same for environment.d
create_envd_export() {
	local -a buf
	for var in "${ENV_EXPORTS[@]}"; do
		if [[ -n ${!var} ]]; then
			printf -v line '%s=%s' "$var" "${!var}"
			buf+=("${line}")
		fi
	done
	local IFS=$'\n'
	printf '%s' "${buf[*]}"
}

is_equal() {
	local file=$1 nbuf=$2
	if [[ -r $file ]]; then
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
	render_exp=$(create_envd_export)
	local -r env=${XDG_CONFIG_HOME}/environment.d
	if [[ ! -r ${env}/50-profile.conf ]]; then
		mkdir -p "$env"
		touch "${env}/50-profile.conf"
	fi
	if ! is_equal "${env}/50-profile.conf" "$render_exp"; then
		printf '%s\n' "${env}/50-profile.conf updated!" >&2
		printf '%s\n' "$render_exp" >"${env}/50-profile.conf"
	fi
}

export_envd() {
	# unused for now, synchronizes env.d + profile variables
	shopt -s nullglob
	local -r envd=${XDG_CONFIG_HOME}/environment.d
	set -a
	if [[ -d $envd ]]; then
		for fragment in "${envd}"/*.conf; do
			if [[ -f $fragment ]]; then
				source "$fragment"
			fi
		done
	fi
	set +a
}

# export for pam_env and avoid unnecessary writes
create_pamd_export() {
	local -a buf
	for var in "${PAM_EXPORTS[@]}"; do
		if [[ -n ${!var} ]]; then
			printf -v line '%-32s DEFAULT=%s' "$var" "${!var}"
			buf+=("${line}")
		fi
	done
	local IFS=$'\n'
	printf '%s' "${buf[*]}"
}

# looks for machineid.conf fragments
source_machine_profile() {
	local machine=$(</etc/machine-id)
	if [[ -n $machine ]]; then
		local -r ppath=${XDG_CONFIG_HOME}/profile/machine.d/${machine}
		if [[ -d $ppath ]]; then
			for frag in "${ppath}"/*.conf; do
				if [[ -f $frag ]]; then
					source "$frag"
				fi
			done
		elif [[ -r ${HOME}/.profile-${machine}.conf ]]; then
			source "${HOME}/.profile-${machine}.conf"
		fi
	fi
}

# looks for hostname.conf fragments
source_host_profile() {
	local host=${HOSTNAME:-$(</proc/sys/kernel/hostname)}
	host=${host,,}
	if [[ -n $host ]]; then
		local -r ppath=${XDG_CONFIG_HOME}/profile/host.d/${host}
		if [[ -d $ppath ]]; then
			for frag in "${ppath}"/*.conf; do
				if [[ -f $frag ]]; then
					source "$frag"
				fi
			done
		elif [[ -r ${HOME}/.profile-${host}.conf ]]; then
			source "${HOME}/.profile-${host}.conf"
		fi
	fi
}

# looks for user.conf fragments
source_user_profile() {
	local -r ppath=${XDG_CONFIG_HOME}/profile/user.d/${LOGNAME}
	if [[ -d ${ppath} ]]; then
		for frag in "${ppath}"/*.conf; do
			if [[ -f $frag ]]; then
				source "$frag"
			fi
		done
	elif [[ -r ${HOME}/.profile-${LOGNAME}.conf ]]; then
		source "${HOME}/.profile-${LOGNAME}.conf"
	fi
}

# looks for user@host.conf fragments
source_userhost_profile() {
	local host=${HOSTNAME:-$(</proc/sys/kernel/hostname)}
	host=${host,,}
	if [[ -n $host ]]; then
		local -r ppath=${XDG_CONFIG_HOME}/profile/user@host.d/${LOGNAME}@${host}
		if [[ -d $ppath ]]; then
			for frag in "${ppath}"/*.conf; do
				if [[ -f $frag ]]; then
					source "$frag"
				fi
			done
		elif [[ -r ${HOME}/.profile-${LOGNAME}@${host}.conf ]]; then
			source "${HOME}/.profile-${LOGNAME}@${host}.conf"
		fi
	fi
}

# looks for manually conf -> conf.d linked fragments
source_conf_profile() {
	local -r ppath=${XDG_CONFIG_HOME}/profile/conf.d
	if [[ -d ${ppath} ]]; then
		for frag in "${ppath}"/*.conf; do
			if [[ -f $frag ]]; then
				source "$frag"
			fi
		done
	fi
}


# priority higher -> lower, decreasing specificity
# conf > user@host > user > machine > host
source_host_profile
source_machine_profile
source_user_profile
source_userhost_profile
source_conf_profile

# export canonicalized 'PATH_EXPORTS' entries after sourcing host specific profile
export_user_paths

# has to be manually called by the user
generate-env() {
	write_pamd_exports
	write_envd_exports
}