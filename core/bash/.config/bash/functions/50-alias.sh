# vi:set ft=bash ts=4 sw=4 noet noai:
on_debug

alias mu='ncmpcpp -q'
alias xnobar="xprop \
	-id \$(xdotool getactivewindow) \
	-f _MOTIF_WM_HINTS 32c \
	-set _MOTIF_WM_HINTS '0x2, 0x0, 0x0, 0x0, 0x0'"
