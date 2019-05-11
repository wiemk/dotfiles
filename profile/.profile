# ~/.profile
# you can override exported variables in host specific profiles in
# ${XDG_CONFIG_HOME}/profile/profile-${HOSTNAME}
# shellcheck disable=2155,2039,2043,1090
is_cmd() {
	hash "$1" &>/dev/null && return 0
	return 1
}

#################################################
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
if [[ -d "${HOME}/tmp" ]]; then
	XDG_CACHE_HOME="${HOME}/tmp/.cache"
	TMPDIR="${HOME}/tmp"
else
	XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
fi
export XDG_CACHE_HOME TMPDIR
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
	# solarized8_flat or OceanicNext
	export NVIM_THEME='solarized8_flat'
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

#################################################
# define additional PATH folders here
path_exports=("${XDG_DATA_HOME}/../bin")
# read by PAM through the pam_env module (man 8 pam_env) - be aware that fedora
# is using a patched pam_env module which does not enable user_readenv by default
# touch ${HOME}/.pam_environment for enabling
pam_exports=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME TMPDIR PATH)
# environment.d (man 8 environment.d) read by systemd-environment-d-generator
# (man 8 systemd-environment-d-generator), initialized with default pam_exports
# touch ${XDG_CONFIG_HOME}/environment.d/50-profile.conf for enabling
env_exports=("${pam_exports[@]}")

#################################################
# source host specific profile
source_machine_profile() {
	local machine=${HOST:-$HOSTNAME}
	machine=$(printf "%s" "$machine" | tr '[:upper:]' '[:lower:]')
	if [[ -n ${machine+x} ]]; then
		if [[ -r "${HOME}/.profile-${machine}" ]]; then
			source "${HOME}/.profile-${machine}"
		elif [[ -r "${XDG_CONFIG_HOME}/profile/profile-${machine}" ]]; then
			source "${XDG_CONFIG_HOME}/profile/profile-${machine}"
		fi
	fi
}
source_machine_profile

# export canonicalized 'path_exports' entries after sourcing host specific profile
export_path() {
	local -a rpath
	if is_cmd realpath; then
		for (( i=0; i < ${#path_exports[@]}; i++ )); do
			local realp="$(realpath -qms "${path_exports[$i]}")"
			if ! [[ "$PATH" =~ $realp ]]; then
				rpath+=("$realp")
			fi
			unset realp
		done
		unset i path_exports
	fi
	local path=("${rpath[@]}" "$PATH")
	printf -v spath '%s:' "${path[@]%/}"
	PATH="${spath:0:-1}"
	export PATH
}
export_path

# export for pam_env and avoid unnecessary writes
create_pam_export() {
	local estr=()
	for var in "${pam_exports[@]}"; do
		printf -v buf '%-32s DEFAULT=%s\n' "$var" "${!var}"
		estr+=("${buf}")
		unset buf
	done
	local IFS=''
	local buf="${estr[*]}"
	unset IFS
	echo -e "${buf%?}"
}

# same for environment.d
create_env_export() {
	local estr=()
	for var in "${env_exports[@]}"; do
		printf -v buf '%s=%s\n' "$var" "${!var}"
		estr+=("${buf}")
		unset buf
	done
	local IFS=''
	local buf="${estr[*]}"
	unset IFS
	echo -e "${buf%?}"
}

is_identical() {
	local file="$1"
	local nbuf="$2"
	if [[ -f "${file}" ]]; then
		local obuf="$(<"${file}")"
		local ohash=$(echo "${obuf}" | command sha1sum | cut -d ' ' -f1)
		local nhash=$(echo "${nbuf}" | command sha1sum | cut -d ' ' -f1)
		if [[ "$ohash" == "$nhash" ]]; then
			return 0
		fi
		return 1
	fi
}

write_pam_export() {
	render_exp="$(create_pam_export)"
	if ! is_identical "${HOME}/.pam_environment" "$render_exp"; then
		echo >&2 "${HOME}/.pam_environment updated"
		echo "$render_exp" > "${HOME}/.pam_environment"
	fi
}
write_pam_export

write_env_export() {
	render_exp="$(create_env_export)"
	if ! is_identical "${XDG_CONFIG_HOME}/environment.d/50-profile.conf" "$render_exp"; then
		echo >&2 "${XDG_CONFIG_HOME}/environment.d/50-profile.conf updated"
		echo "$render_exp" > "${XDG_CONFIG_HOME}/environment.d/50-profile.conf"
	fi
}
write_env_export

#################################################
export PROFILE_SOURCED=true

# DEBUG
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	echo "$(date +%s): .profile" >> "${HOME}/shell_debug.log"
fi
# EOF
