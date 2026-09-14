PREFIX ?= /usr
DESTDIR ?=
INSTALL ?= install
RM ?= rm -f

.DEFAULT_GOAL := help

.PHONY: help install uninstall validate release-archive clean

help:
	@echo "Available targets:"
	@echo "  make build"
	@echo "  make install"
	@echo "  make uninstall"
	@echo "  make validate"
	@echo "  make release-archive"

install:
	$(INSTALL) -Dm755 bin/argvus-displayctl \
		"$(DESTDIR)$(PREFIX)/bin/argvus-displayctl"
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus/display"
	cp -a src/usr/share/argvus/display/. "$(DESTDIR)$(PREFIX)/share/argvus/display/"
	find "$(DESTDIR)$(PREFIX)/share/argvus/display/sh" -type f -name '*.sh' -exec chmod 755 {} \; 2>/dev/null || true
	$(INSTALL) -Dm644 LICENSE \
		"$(DESTDIR)$(PREFIX)/share/licenses/argvus-display/LICENSE"

uninstall:
	$(RM) "$(DESTDIR)$(PREFIX)/bin/argvus-displayctl"
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/display"
	$(RM) "$(DESTDIR)$(PREFIX)/share/licenses/argvus-display/LICENSE"

validate:
	@set -eu; \
	scripts=$$(find bin src -type f \( -name '*.sh' -o -path '*/bin/*' \) | sort); \
	test -n "$$scripts"; \
	for script in $$scripts; do sh -n "$$script"; done; \
	if command -v shellcheck >/dev/null 2>&1; then \
		for script in $$scripts; do shellcheck -e SC1090 -e SC2034 "$$script"; done; \
	else \
		echo "shellcheck not found; skipped"; \
	fi; \
	grep -q 'GENERATED_MONITORS_LUA' src/usr/share/argvus/display/sh/monitor-switch.sh; \
	test -f src/usr/share/argvus/display/sh/nwg-displays-adapter.sh
	@echo "argvus-display validation ok"

release-archive:
	mkdir -p .release
	git archive --format=tar.gz --prefix="argvus-display-$$(git rev-parse --short HEAD)/" \
		--output=".release/argvus-display-$$(git rev-parse --short HEAD).tar.gz" HEAD

.PHONY: build

build:
	@tools/build-local-package.sh

clean:
	rm -rf dist
	rm -f packaging/arch/*.zst packaging/arch/*.tar.gz
