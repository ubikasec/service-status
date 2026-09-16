# Local build helpers for the UBIKA status page.
#
# The Hugo version is pinned in .hugo-version and shared with the GitHub
# Actions workflow (.github/workflows/hugo.yaml). The binary is downloaded
# into .bin/ (git-ignored), so nothing needs to be installed system-wide.
#
#   make build   -> production build into public/ (same flags as CI)
#   make serve   -> live-reload dev server on http://127.0.0.1:1313/
#   make check   -> build + validate the RSS feed used by Power Automate
#   make clean   -> remove public/ and the downloaded binary

HUGO_VERSION := $(shell cat .hugo-version)
BIN_DIR      := .bin
HUGO         := $(BIN_DIR)/hugo
OS           := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH         := $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
HUGO_TGZ     := hugo_extended_$(HUGO_VERSION)_$(OS)-$(ARCH).tar.gz
HUGO_URL     := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_TGZ)

.PHONY: all hugo build serve check clean

all: check

# Download Hugo Extended $(HUGO_VERSION) if missing or if the pinned version changed.
hugo: $(HUGO)

$(HUGO): .hugo-version
	@mkdir -p $(BIN_DIR)
	@echo "Downloading Hugo Extended $(HUGO_VERSION) ($(OS)/$(ARCH))"
	@curl -sSL -o $(BIN_DIR)/$(HUGO_TGZ) "$(HUGO_URL)"
	@tar -xzf $(BIN_DIR)/$(HUGO_TGZ) -C $(BIN_DIR) hugo
	@rm -f $(BIN_DIR)/$(HUGO_TGZ)
	@touch $(HUGO)
	@$(HUGO) version

# Only initialise the theme submodule when it is missing: never reset it to
# the recorded commit, so a locally checked-out theme version is preserved.
themes/cstate/theme.toml:
	git submodule update --init --recursive

build: $(HUGO) themes/cstate/theme.toml
	HUGO_ENVIRONMENT=production HUGO_ENV=production $(HUGO) --minify

serve: $(HUGO) themes/cstate/theme.toml
	$(HUGO) server --buildDrafts --buildFuture --baseURL http://127.0.0.1:1313/

check: build
	@echo "Checking public/index.xml"
	@xmllint --noout public/index.xml
	@test "$$(grep -c '<item>' public/index.xml)" -gt 0
	@grep -q '<category>status:' public/index.xml
	@echo "Items:      $$(grep -c '<item>' public/index.xml)"
	@echo "Categories: $$(grep -o '<category>[^:]*:' public/index.xml | sed 's/<category>//; s/:$$//' | sort | uniq -c | sort -rn | awk '{printf "%s=%s ", $$2, $$1}')"
	@echo "RSS feed OK"

clean:
	rm -rf public $(BIN_DIR)
