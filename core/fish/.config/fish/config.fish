if not functions -q fisher
	set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
	curl -sL "https://raw.githubusercontent.com/jorgebucaran/fisher/master/fisher.fish" --create-dirs -o "$XDG_CONFIG_HOME/fish/functions/fisher.fish"
	source "$XDG_CONFIG_HOME/fish/functions/fisher.fish"
	fisher update
end
