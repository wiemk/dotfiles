# vi: set ft=sh ts=4 sw=4 sts=-1 sr et si tw=0 fdm=manual:
# shellcheck shell=bash

init_debug

info_env() {
	local -r cfg=$XDG_CONFIG_HOME/bash/source.d
	local -r abs=$(readlink -f -- "$cfg/..")
	if [[ -d $abs ]]; then
		if has tree; then
			tree -aC -I '.gitkeep' "$abs"
		else
			command ls -1 "$cfg"
		fi
	fi
}

info_key() {
	cat <<-'EOF'

		Readline emacs key mappings:

		[C-p]:		Same as Up arrow
		[C-n]:		Same as Down arrow
		[C-r]:		Begins a backward search through command history (keep pressing [C-r] to move backward)
		[C-s]:		To stop output to terminal
		[C-q]:		To resume output to terminal after [C-s]
		[C-a]:		Move to the beginning of line
		[C-e]:		Move to the end of line
		[C-f]:		Move forward one character
		[C-b]:		Move backward one character
		[C-d]:		Deletes the character under the cursor, EOF otherwise
		[C-k]:		Delete all text from the cursor to the end of line
		[C-l]:		Equivalent to clear
		[C-t]:		Transpose the character before the cursor with the one under the cursor
		[ESC-t]:	Transposes the two words before the cursor
		[C-w]:		Cut the word before the cursor
		[C-u]:		Cut the line before the cursor
		[C-y]:		Paste buffer
		[C-_]:		Undo input

		[C-x-BS]:	Delete all text from the beginning of line to the cursor
		[C-x][C-e]:	Launch $EDITOR with current input as buffer
	EOF
}