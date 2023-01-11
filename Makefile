SHELL := /usr/bin/bash
.DEFAULT_GOAL := help

CORE := $(wildcard core/*)
STOW := $(shell command -v stow 2>/dev/null)

format: format-sh format-lua
link: link-bash link-bin stow-core

.PHONY: help lint format link format-sh link-bash link-bin stow-core

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

lint: ## lint sh/bash files with shellcheck
	@shfmt -f . | xargs shellcheck --external-sources --exclude=SC1091

format-sh: lint ## format sh/bash files
	@shfmt -f . | xargs shfmt --case-indent --binary-next-line --simplify --write

format-lua: ## format lua files
	@git ls-files | grep -E '*.lua$$' | xargs stylua --config-path .stylua.toml

link-bash: ## link bash functions
	@core/bash/.config/bash/link.sh

link-bin: ## link shell scripts to ~/.local/bin
	@bin/link.sh

stow-core: ## stow core/*
ifndef STOW
	$(error 'target requires GNU stow')
endif
	@stow -t $(HOME) -d core/ -S $(foreach c,$(CORE),$(notdir $(c)));