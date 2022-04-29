#!/bin/sh
# vim ft=sh ts=4 sw=4 noet

sleep=$1 active=$2 id=$3
hook_enabled=$(tmux display-message -p -t "${id}" '#{@alert_hook}')

if [ "${active}" -eq 1 ] || [ "${hook_enabled}" != on ]; then
	exit
fi

session=$4 index=$5 name=$6
ts="${XDG_RUNTIME_DIR}/tmux-alert.hook"
now=$(date +%s)

if ! [ -e "${ts}" ]; then
	touch "${ts}"
	now=$((now + sleep + 1))
fi

last=$(stat -c '%Y' "${ts}")
if [ $((now - last)) -gt "${sleep}" ]; then
	touch "${ts}"
	notify-send "TMUX:${session} [${index}:${name}]"
fi
