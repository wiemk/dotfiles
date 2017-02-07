# Zsh always executes /etc/zsh/zshenv and $ZDOTDIR/.zshenv
# If the shell is a login shell, commands are read from /etc/profile and then $ZDOTDIR/.zprofile
# If the shell is interactive, commands are read from /etc/zsh/zshrc and then $ZDOTDIR/.zshrc
# Finally, if the shell is a login shell, /etc/zsh/zlogin and $ZDOTDIR/.zlogin are read.
# (a) always, (l) login, (i) interactive
# .zshenv (a) -> [.profile ->] .zprofile (l) -> .zshrc (i) -> .zlogin (l)

ZDOTDIR=~/.config/zsh

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
	source "${ZDOTDIR:-$HOME}/.zprofile"
fi
