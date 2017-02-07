### Dotfiles managed with GNU Stow.

**general usage:**
```stow -d dotfiles/ -t $HOME -S <target>```

**profile:**
- environment variables and simple login functions, sources machine ($HOST or $HOSTNAME) specific profile (profile-$HOST)
- XDG variables are set

**zsh:**
- wrapper around oh-my-zsh is kept lean, providing only a skeleton configuration for hooking in own settings and functions
- sources *~/.profile* (has priority) or *~/.config/profile/.profile* in sh emulation mode so you can use it for bash aswell
- zsh specific profile settings should go to *.zprofile*
- additional functions should be symlinked from *functions/available* to *functions/enabled*
- tries to load oh-my-zsh, clones it to *$XDG_DATA_HOME/oh-my-zsh* if not available
- oh-my-zsh specific configuration should go to *~/.config/zsh/oh-my-zsh/.omzshrc* (theme, plugins, ..)
- oh-my-zsh custom folder is *$ZDOTDIR/oh-my-zsh* (usually *~/.config/zsh/oh-my-zsh*)
