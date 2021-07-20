# vim: ft=fish ts=4 sw=4 noet
# Make ls use colors if we are on a system that supports that feature and writing to stdout.
#
if command ls --version >/dev/null 2>/dev/null
	# This appears to be GNU ls.
	function ls --description "List contents of directory"
		set -l param --color=auto
		if isatty 1
			set -l param --indicator-style=classify
		end
		command ls $param $argv
	end

	if not set -q LS_COLORS
		if command -sq vivid and set -q VIVID_LS_THEME
			set -gx LS_COLORS (vivid generate $VIVID_LS_THEME)
		else if command -sq dircolors
			set -l colorfile
			for file in ~/.dir_colors ~/.dircolors /etc/DIR_COLORS
				if test -f $file
					set colorfile $file
					break
				end
			end
			# Here we rely on the legacy behavior of `dircolors -c` producing output suitable for
			# csh in order to extract just the data we're interested in.
			set -gx LS_COLORS (dircolors -c $colorfile | string split ' ')[3]
			# The value should always be quoted but be conservative and check first.
			if string match -qr '^([\'"]).*\1$' -- $LS_COLORS
				set LS_COLORS (string match -r '^.(.*).$' $LS_COLORS)[2]
			end
		end
	end
end

