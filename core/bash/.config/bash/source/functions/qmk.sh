# vi: set ft=sh ts=4 sw=4 sts=-1 sr noet si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

ifclean() {
	# kernel 5.19.x netavark workaround
	while read -r link; do
		sudo ip link del "$link"
	done < <(ip -o link | awk -F: '/(podman[[:digit:]]+|veth[[:xdigit:]]+@if[[:xdigit:]]*):/ {sub("@if[[:digit:]]", "", $2); print $2}')
}

flash_stm32l432() {
	printf "\nPlease press QK_BOOT to start the flashing process.\n"
	dfu-util -a 0 -d 0483:DF11 -s 0x8000000:leave -D "$1" -w
}

qmk() {
	sudo -v
	sudo -- podman pull qmkfm/qmk_cli
	sudo -- podman run --uidmap 0:"$(id -u)":65536 --gidmap=0:"$(id -g)":65536 --rm -it \
		--hostname qmk --tmpfs /tmp:exec,rw -v ~/dev/projects/qmk_firmware:/qmk:rw \
		--security-opt label=disable --workdir /qmk --env 'OPT=2' qmkfm/qmk_cli \
		sh -c 'qmk setup -y; qmk compile -kb keychron/q1/q1_ansi_stm32l432 -km norgb' || {
		ifclean
		return 1
	} && ifclean

	local fw=keychron_q1_q1_ansi_stm32l432_norgb.bin
	if [[ -e "${fw}.orig" ]]; then
		if cmp -s "${fw}" "${fw}.orig"; then
			printf "\nOutput is identical the the previous firmware.\n"
			return 0
		else
			printf "\nFirmware is different than previous one, proceeding.\n"
		fi
	fi

	command cp -vuf "$fw" "${fw}.orig"
	local dest=/home/${LOGNAME}/cstorage/backup/firmware/keychron/archive
	if [[ -d $dest ]]; then
		local rev
		rev=$(git rev-parse --short @~1)
		if [[ -n $rev ]]; then
			command cp -v "$fw" "${dest}/${rev}_${fw}"
		fi
	fi

	if prompt "Download firmware to keyboard?"; then
		flash_stm32l432 "$fw"
	fi
}