# ~/.profile
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
if [[ -d "${HOME}/tmp" ]]; then
	XDG_CACHE_HOME="${HOME}/tmp/.cache"
else
	XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
fi
export XDG_CACHE_HOME
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}

# default applications by env
# emacs > nvim > vim > vi
EDITOR=vi
if hash emacsclient &>/dev/null; then
	EDITOR='emacsclient -qcn --alternate-editor=emacs'
elif hash nvim &>/dev/null; then
	EDITOR=nvim
	# solarized8_flat or OceanicNext
	export NVIM_THEME=solarized8_flat
elif hash vim &>/dev/null; then
	EDITOR=vim
fi
export EDITOR

export SUDO_EDITOR=vi
export ALTERNATE_EDITOR=vi
export VISUAL=$EDITOR
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE="${XDG_CACHE_HOME}/lesshist"

# define additional PATH folders here
pathar=("${XDG_DATA_HOME}/../bin")
# variables visible for systemd --user
pam_exports=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME PATH)

# source host specific profile
machine=${HOST:-$HOSTNAME}
machine=$(printf "%s" $machine | tr '[:upper:]' '[:lower:]')
# https://stackoverflow.com/a/13864829
if [[ ! -z ${machine+x} ]]; then
	if [[ -r "${HOME}/.profile-${machine}" ]]; then
		source "${HOME}/.profile-${machine}"
	elif [[ -r "${XDG_CONFIG_HOME}/profile/profile-${machine}" ]]; then
		source "${XDG_CONFIG_HOME}/profile/profile-${machine}"
	fi
fi

# export after sourcing host specific profile
if hash realpath &>/dev/null; then
	for (( i=0; i < ${#pathar[@]}; i++ )); do
		realp="$(realpath -qms "${pathar[$i]}")"
		if ! [[ "$PATH" =~ "$realp" ]]; then
			spath+=("$realp")
		fi
		unset realp
	done
	unset i pathar
fi
path=("${spath[@]}" "$PATH")
path="$( printf '%s:' "${path[@]%/}" )"
path="${path:0:-1}"
export PATH="$path"
unset path spath

# export for pam_env and avoid unnecessary writes
create_export() {
	local estr=()
	for var in ${pam_exports[@]}; do
		printf -v buf '%s\t\tDEFAULT=%s\n' $var "${!var}"
		estr+=("${buf}")
		unset buf
	done
	local buf="${estr[@]}"
	buf=${buf%?}
	echo -e "${buf}"
}

is_identical() {
	local pamenv="${HOME}/.pam_environment"
	local nbuf="$1"
	if [[ -f "${pamenv}" ]]; then
		local obuf="$(<"${pamenv}")"
		local ohash=$(echo "${obuf}" | command sha1sum | cut -d ' ' -f1)
		local nhash=$(echo "${nbuf}" | command sha1sum | cut -d ' ' -f1)
		if [[ $ohash == $nhash ]]; then
			return 0
		fi
		return 1
	fi
}

render_exp="$(create_export)"
if ! is_identical "$render_exp"; then
	echo "$render_exp" > "${HOME}/.pam_environment"
fi
#################################################
export PROFILE_SOURCED=true

# debug
if [[ -e "${XDG_CONFIG_HOME}/profile/_debug" ]]; then
	echo "$(date +%s): .profile" >> "${HOME}/shell_debug.log"
fi
# EOF
