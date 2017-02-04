for i (${ZDOTDIR:-$HOME/.config/zsh}/functions/enabled/*.zsh(N)); do
	if [[ -r "$i" ]]; then
		source "$i"
	fi
done
unset i

# check if oh-my-zsh is available
if [[ -f $ZDOTDIR/oh-my-zsh/.omzshrc ]]; then
	source $ZDOTDIR/oh-my-zsh/.omzshrc
fi

# extra completion files
if [[ -d /usr/share/fzf ]]; then
	source /usr/share/fzf/completion.zsh
	source /usr/share/fzf/key-bindings.zsh
fi
