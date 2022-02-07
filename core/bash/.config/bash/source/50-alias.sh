# vi:set ft=bash ts=4 sw=4 noet noai:

on_debug

alias xnobar="xprop \
	-id \$(xdotool getactivewindow) \
	-f _MOTIF_WM_HINTS 32c \
	-set _MOTIF_WM_HINTS '0x2, 0x0, 0x0, 0x0, 0x0'"

code() { flatpak run com.vscodium.codium --no-sandbox "$@" 2>/dev/null; }

rdp() { systemd-run --quiet --user --collect xfreerdp /network:auto /rfx /dvc:echo /w:1600 /h:900 /dvc:echo /geometry /cert:ignore +compression +async-channels +async-input -encryption -grab-keyboard /v:"${1}" /u:"${2}" /p:"${3}" "${@:4}"; }