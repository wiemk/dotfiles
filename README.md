#### Linking

The `core`, `bin`, `extra`, or `staging` are designed to be used with [GNU stow](https://www.gnu.org/software/stow/).

##### Using GNU Stow

```sh
stow -d "$REPO/{core,bin,extra,staging}" -t "$HOME" -S <config>
```

#### Examples

```sh
git clone --depth=1 --branch=main -- https://betaco.de/strom/dotfiles.git dotfiles
stow -d "$PWD/dotfiles/core" -t "$HOME" -S tmux
```

##### This example will create the following symbolic links:

1. `~/.tmux.conf` 🡒 `$PWD/zeno-dotfiles/core/tmux/.tmux.conf`
2. `~/.config/tmux` 🡒 `$PWD/zeno-dotfiles/core/tmux/.config/tmux`

#### Notes

Directories in **[staging](staging/)** may be disappeared at any time.