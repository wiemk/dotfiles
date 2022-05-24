# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash

init_debug

# Dircolors matching theme
if [[ -n $VIVID_LS_THEME ]] && has vivid; then
	# fedora uses this variable to detect custom LS_COLORS
	LS_COLORS="$(vivid generate "$VIVID_LS_THEME" 2>/dev/null)"
	if [[ -n $LS_COLORS ]]; then
		export LS_COLORS
		export USER_LS_COLORS=$VIVID_LS_THEME
	fi
fi
