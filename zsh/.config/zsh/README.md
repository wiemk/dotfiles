There should be a zshrc and zshrc.local (!) in /etc/zsh for system wide configuration purposes, corresponding to grml.org layout.
Zsh always executes /etc/zsh/zshenv and $ZDOTDIR/.zshenv so do not bloat these files.
If the shell is a login shell, commands are read from /etc/profile and then $ZDOTDIR/.zprofile. Then, if the shell is interactive, commands are read from /etc/zsh/zshrc and then $ZDOTDIR/.zshrc. Finally, if the shell is a login shell, /etc/zsh/zlogin and $ZDOTDIR/.zlogin are read.
