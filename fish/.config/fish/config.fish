set SPACEFISH_PROMPT_ORDER time user dir host git package docker golang rust pyenv exec_time line_sep jobs exit_code char
set SPACEFISH_EXEC_TIME_COLOR cyan
set SPACEFISH_TIME_COLOR cyan
set SPACEFISH_USER_COLOR cyan

if not functions -q fisher
	set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
	curl https://raw.githubusercontent.com/jorgebucaran/fisher/master/fisher.fish --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
	fish -c fisher
end

if not type -q fzy
	echo "Please install fzy (https://github.com/jhawthorn/fzy)."
end
