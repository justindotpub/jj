# Makefile for common Cargo tasks

BIN ?= jj
CARGO ?= cargo

# Pass CLI args like: make run ARGS="say --name Alice"
ARGS ?=

# Completions: choose shell and output dir
COMP_SHELL ?= zsh
OUT_DIR ?= completions

.PHONY: help build release run test check fmt fmt-check clippy lint clean install completions ci bump

.DEFAULT_GOAL := help

help: ## Show this help.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $1, $2}'

build: ## Build debug binary
	$(CARGO) build

release: ## Build optimized release binary
	$(CARGO) build --release

run: ## Run the CLI (use ARGS="...")
	$(CARGO) run -- $(ARGS)

test: ## Run tests
	$(CARGO) test

check: ## Type-check without building artifacts
	$(CARGO) check

fmt: ## Format the codebase
	$(CARGO) fmt --all

fmt-check: ## Check formatting without writing changes
	$(CARGO) fmt --all -- --check

clippy: ## Lint with clippy (deny warnings)
	$(CARGO) clippy -- -D warnings

lint: fmt-check clippy ## Run format check and clippy

clean: ## Clean target directory
	$(CARGO) clean

install: ## Install the binary from this workspace
	$(CARGO) install --path . --force

completions: ## Generate shell completions to OUT_DIR for COMP_SHELL
	@mkdir -p $(OUT_DIR)
	@$(CARGO) run -- generate $(COMP_SHELL) > $(OUT_DIR)/$(BIN).$(COMP_SHELL)
	@echo "Wrote $(OUT_DIR)/$(BIN).$(COMP_SHELL)"

ci: ## Run checks used in CI (fmt-check, clippy, test)
	$(MAKE) fmt-check
	$(MAKE) clippy
	$(MAKE) test

bump: ## Bump crate version, commit, push, and tag (default: patch; override with VERSION=X.Y.Z)
	@set -e; \
	if [ -z "$(VERSION)" ]; then \
		cur=$$(grep '^version = ' Cargo.toml | sed 's/.*version = "\([^"\\]*\)".*/\1/'); \
		[ -n "$$cur" ] || { echo "Could not parse current version" >&2; exit 1; }; \
		major=$${cur%%.*}; rest=$${cur#*.}; minor=$${rest%%.*}; patch=$${rest#*.}; \
		case "$$major.$$minor.$$patch" in \
			*[^0-9.]*|\" ) echo "Could not parse current version: '$$cur'" >&2; exit 1 ;; \
		esac; \
		new_patch=$$((patch + 1)); \
		NEW_VER="$$major.$$minor.$$new_patch"; \
		echo "VERSION not provided; bumping to next patch: $$NEW_VER"; \
	else \
		NEW_VER="$(VERSION)"; \
		echo "Bumping to specified version: $(VERSION)"; \
	fi; \
	if command -v cargo-set-version >/dev/null 2>&1; then \
		$(CARGO) set-version $$NEW_VER; \
	else \
		echo "cargo-edit not found; using sed to update Cargo.toml"; \
		sed -i.bak "s/^version = \"[^\"]*\"/version = \"$$NEW_VER\"/" Cargo.toml && rm Cargo.toml.bak; \
	fi; \
	echo "Updating Cargo.lock by building the project..."; \
	$(CARGO) build; \
	echo "Committing and pushing version bump..."; \
	git add Cargo.toml Cargo.lock; \
	git commit -m "release: v$$NEW_VER"; \
	git push; \
	echo "Tagging release and pushing tag..."; \
	git tag -a "v$$NEW_VER" -m "release: v$$NEW_VER"; \
	git push origin "v$$NEW_VER"; \
	echo "Bump to v$$NEW_VER complete."
