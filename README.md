### Dotfiles managed with GNU Stow.

**general usage:**
```stow -d dotfiles/ -t $HOME -S <target>```

**profile:**
- environment variables and simple login functions, sources machine ($HOST or $HOSTNAME) specific profile (profile-$HOST)
- XDG variables are set
- *~.xprofile* sources *~.profile* if needed

**zsh:**
- sources *~/.profile* (has priority) or *~/.config/profile/.profile* in sh emulation mode so you can use it for bash aswell, generic environmental variable definition should go here
- uses zplug to load various modules, utilizes some prezto modules by default, edit in *.zshrc*
- additional functions should be symlinked from *func/\<name\>.zsh* to *func-enabled/\<name\>.zsh*, which are added by zplug as a single, local plugin, extending *fpath*
- all non environmental variable settings should reside in *.zshrc* or, if modular, *func/\<name\>.zsh* (see above)
- it is recommended that more advanced and intrusive settings/features go to the *plugins/* directory and are added manually to *.zshrc*, utilizing zplug
