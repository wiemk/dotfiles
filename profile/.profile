# ~/.profile
# touch ~/.pam_environment if you want to use environment
# variables set by pam (useful for systemd user services)
# shellcheck disable=2155,2043,1090
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
if [[ -d "${HOME}/tmp" ]]; then
	XDG_CACHE_HOME="${HOME}/tmp/.cache"
else
	XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
fi
export XDG_CACHE_HOME
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}

has_cmd() {
	hash "$1" &>/dev/null && return 0
	return 1
}

# default applications by env
# emacs > nvim > vim > vi
EDITOR='vi'
if has_cmd emacsclient; then
	EDITOR='emacsclient -qcn -a emacs'
elif has_cmd nvim; then
	EDITOR='nvim'
	# solarized8_flat or OceanicNext
	export NVIM_THEME='solarized8_flat'
elif has_cmd vim; then
	EDITOR='vim'
fi
export EDITOR

export SUDO_EDITOR='vi'
export ALTERNATE_EDITOR='vi'
export VISUAL="${EDITOR}"
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE="${XDG_CACHE_HOME}/lesshist"

# define additional PATH folders here
path_exports=("${XDG_DATA_HOME}/../bin")
# variables visible for systemd --user
pam_exports=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME PATH)

# source host specific profile
machine=${HOST:-$HOSTNAME}
machine=$(printf "%s" "$machine" | tr '[:upper:]' '[:lower:]')
if [[ -n ${machine+x} ]]; then
	if [[ -r "${HOME}/.profile-${machine}" ]]; then
		source "${HOME}/.profile-${machine}"
	elif [[ -r "${XDG_CONFIG_HOME}/profile/profile-${machine}" ]]; then
		source "${XDG_CONFIG_HOME}/profile/profile-${machine}"
	fi
fi

# export canonicalized 'path_exports' entries after sourcing host specific profile
export_path() {
	local -a rpath
	if has_cmd realpath; then
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
create_export() {
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

is_identical() {
	local pamenv="${HOME}/.pam_environment"
	local nbuf="$1"
	if [[ -f "${pamenv}" ]]; then
		local obuf="$(<"${pamenv}")"
		local ohash=$(echo "${obuf}" | command sha1sum | cut -d ' ' -f1)
		local nhash=$(echo "${nbuf}" | command sha1sum | cut -d ' ' -f1)
		if [[ "$ohash" == "$nhash" ]]; then
			return 0
		fi
		return 1
	fi
}

render_exp="$(create_export)"
if ! is_identical "$render_exp"; then
	echo >&2 "~/.pam_environment updated"
	echo "$render_exp" > "${HOME}/.pam_environment"
fi
#################################################
export PROFILE_SOURCED=true

# debug
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	echo "$(date +%s): .profile" >> "${HOME}/shell_debug.log"
fi
# EOF
