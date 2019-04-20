### Dotfiles managed with GNU Stow.

**general usage:**
```stow -d dotfiles/ -t $HOME -S <target>```

**profile:**
- environment variables and simple login functions, sources machine ($HOST or $HOSTNAME) specific profile (profile-$HOST)
- XDG variables are set
- *~.xprofile* sources *~.profile* if needed
