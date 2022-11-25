SHELL := /usr/bin/env bash

format: format-sh format-lua
link: link-bash link-bin stow-core

.DEFAULT: format

lint:
	@shfmt -f . | xargs shellcheck --external-sources --exclude=SC1091

format-sh: lint
	@shfmt -f . | xargs shfmt --case-indent --binary-next-line --simplify --write

format-lua:
	@git ls-files | grep -E '*.lua$$' | xargs stylua --config-path .stylua.toml

link-bash:
	@core/bash/.config/bash/link.sh

link-bin:
	@bin/link.sh

CORE := $(wildcard core/*)
stow-core:
	@$(foreach c,$(CORE),stow -t $(HOME) -S $(c);)

.PHONY: lint format link format-sh link-bash link-bin stow-core