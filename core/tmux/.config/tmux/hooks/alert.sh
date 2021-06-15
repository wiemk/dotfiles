#!/bin/sh
# vim ft=sh ts=4 sw=4 noet

if [ "${2}" -eq 1 ]; then
	exit
fi

TS="${XDG_RUNTIME_DIR}/tmux-alert.hook"

now=$(date '+%s')
if ! [ -e "${TS}" ]; then
	touch "${TS}"
	now=$((now + ${1} + 1))
fi

last=$(stat -c '%Y' "${TS}")
if [ $((now - last)) -gt "${1}" ]; then
	touch "${TS}"
	notify-send "tmux [${3}]: [${4}:${5}]"
fi

