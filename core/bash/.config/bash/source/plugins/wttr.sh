# vi:set ft=bash ts=4 sw=4 noet noai:

# If you source this file, it will set wttr_params as well as show weather.

# wttr_params is space-separated URL parameters, many of which are single characters that can be
# lumped together. For example, "F q m" behaves the same as "Fqm".
_wttr_param() {
	declare -a wttr_params
	if [[ ! -v wttr_params[@] ]]; then
		# Form localized URL parameters for curl
		if [[ -t 1 ]] && [[ "$(tput cols)" -lt 125 ]]; then
			wttr_params+=('n')
		fi 2>/dev/null

		for tok in $(locale LC_MEASUREMENT); do
			case $tok in
				1) wttr_params+=('m') ;;
				2) wttr_params+=('u') ;;
			esac
		done 2> /dev/null
		wttr_params+=('F')
	fi
	echo "${wttr_params[*]}"
}

wttr() {
	local location="${1// /+}"
	local param; param=$(_wttr_param)
	command shift
	local -a args
	for p in "$param" "$@"; do
		args+=("--data-urlencode" "$p")
	done

	curl -fGsS -H "Accept-Language: ${LANG%_*}" "${args[@]}" --compressed "http://wttr.in/${location}"
}

wttr2() {
	local location="${1// /+}"
	local param; param=$(_wttr_param)
	command shift
	local -a args
	for p in "$param" "$@"; do
		args+=("--data-urlencode" "$p")
	done

	curl -fGsS -H "Accept-Language: ${LANG%_*}" "${args[@]}" --compressed "http://v2.wttr.in/${location}"
}
