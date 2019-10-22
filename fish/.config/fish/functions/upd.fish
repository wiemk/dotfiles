# Defined in - @ line 1
function upd --description 'shortcut for upgrading the system'
	set -l id (grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
	switch "$id"
	case "arch"
	    if ! command -sq pacman; return 1; end
		safe_launch "sudo bash -c 'pacman -Syu --noconfirm $argv && pacman -Sc --noconfirm'"
	case "fedora"
		if ! command -sq dnf; return 1; end
		safe_launch "sudo bash -c 'dnf --assumeyes distro-sync; flatpak update --assumeyes'"
	case *
		echo "unknown distribution" >&2
		return 2
	end
end
