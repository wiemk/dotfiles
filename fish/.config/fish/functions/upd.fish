# Defined in - @ line 1
function upd --description 'alias upd sudo pacman -Syu --noconfirm'
	sudo pacman -Syu --noconfirm $argv;
end
