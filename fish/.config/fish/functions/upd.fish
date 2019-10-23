function upd --description 'shortcut for upgrading the system'
	set os (grep -oP '(?<=^ID_LIKE=).+' /etc/os-release | tr -d '"')
	if [ -z "$os" ]
		set os (grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
	end
	
	switch "$os"
	case "arch"
	    if ! command -sq pacman; return 1; end
		safe_launch "sudo bash -c 'pacman -Syu --noconfirm $argv && pacman -Sc --noconfirm'"
	case "fedora"
		if ! command -sq dnf; return 1; end
		safe_launch "sudo bash -c 'dnf --assumeyes distro-sync; flatpak update --assumeyes'"
	case "debian"
		if ! command -sq apt-get; return 1; end
		safe_launch "sudo bash -c 'apt-get update && apt-get dist-upgrade --assume-yes'"
	case *
		echo "unknown distribution" >&2
		return 2
	end
end
