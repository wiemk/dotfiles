### Dotfiles managed with GNU Stow.

**general usage:**
```stow -d dotfiles/ -t $HOME -S <target>```

**profile:**
- environment variables and simple login functions, sources machine ($HOST or $HOSTNAME) specific profile (profile-$HOST)
- XDG variables are set

**zsh:**
- sources *~/.profile* (has priority) or *~/.config/profile/.profile* in sh emulation mode so you can use it for bash aswell
- zsh specific profile settings should go to *.zprofile*
- additional functions should be symlinked from *func* to *func/enabled*
- uses zplug to load various modules, utilizes some prezto modules
