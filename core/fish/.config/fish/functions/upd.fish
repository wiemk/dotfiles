function upd --description 'shortcut for upgrading the system'
	set os (grep -oP '(?<=^ID_LIKE=).+' /etc/os-release | tr -d '"')
	if [ -z "$os" ]
		set os (grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
	end
	
	switch "$os"
	case "arch"
	    if ! command -sq pacman; return 1; end
		safe_launch "sudo bash -c 'pacman -Syu $argv && pacman -Sc --noconfirm'"
	case "fedora"
		if ! command -sq dnf; return 1; end
		safe_launch "sudo bash -c 'dnf distro-sync'"
	case "debian"
		if ! command -sq apt-get; return 1; end
		safe_launch "sudo bash -c 'apt-get update && apt-get dist-upgrade'"
	case *
		echo "unsupported distribution" >&2
		return 2
	end
	command sync
end
