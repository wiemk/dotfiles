### Installation

The **core**, **extra**, or **staging** subdirectory must be part of the stow directory (`-d`):

```sh
stow -d "$REPO/{core,extra,staging}" -t "$HOME" -S <config>
```

#### Example

```sh
git clone --depth=1 --branch=master -- https://betaco.de/zeno/dotfiles.git dotfiles
stow -d "$PWD/dotfiles/core" -t "$HOME" -S tmux
```

##### This example will create the following symbolic links:

1. `~/.tmux.conf` 🡒 `$PWD/zeno-dotfiles/core/tmux/.tmux.conf`
2. `~/.config/tmux` 🡒 `$PWD/zeno-dotfiles/core/tmux/.config/tmux`

