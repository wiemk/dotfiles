#### Linking

The `core`, `extra`, or `staging` are designed to be used with [GNU stow](https://www.gnu.org/software/stow/).

##### Using GNU Stow

```sh
stow -d "$REPO/{core,extra,staging}" -t "$HOME" -S package…
```

#### Examples

```sh
git clone --depth=1 --branch=main -- https://betaco.de/strom/dotfiles.git
stow -d "./dotfiles/core" -t "$HOME" -S tmux readline
```

##### This example will create the following symbolic links:

1. `~/.inputrc` 🡒 `./dotfiles/core/readline/.inputrc`
2. `~/.config/tmux/tmux.conf` 🡒 `./dotfiles/core/tmux/.config/tmux.conf`

#### Notes

Directories in **[staging](staging/)** may be disappeared at any time.