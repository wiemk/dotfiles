if status is-interactive
    # Commands to run in interactive sessions can go here
end

if not functions -q fisher
        set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

if command -sq zoxide 2>/dev/null
	zoxide init fish | source
	bind \cx zi
end
