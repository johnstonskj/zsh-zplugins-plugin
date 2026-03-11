# -*- mode: makefile-gmake -*-

PLUGIN_FILE=$(CURDIR)/zplugins.plugin.zsh
FUNCTION_DIR=$(CURDIR)/functions
FUNCTIONS=$(wildcard $FUNCTION_DIR)/*)
MODULE_DIR=$(CURDIR)/modules
MODULES=$(wildcard $(MODULE_DIR)/*.zsh)
SOURCES=$(PLUGIN_FILE) $(MODULES)
DOC_DIR=$(CURDIR)/doc

all: shdoc

DOC_CMD=shdoc
DOC_INDEX=$(DOC_DIR)/index.md
DOC_FILES=$(DOC_INDEX) $(patsubst $(MODULE_DIR)/%.zsh,$(DOC_DIR)/%.md,$(wildcard $(MODULE_DIR)/*.zsh))

$(DOC_DIR):
	mkdir -p $(DOC_DIR)

$(DOC_INDEX) : $(PLUGIN_FILE)
	$(DOC_CMD) $< > $@

$(DOC_DIR)/%.md : $(MODULE_DIR)/%.zsh
	$(DOC_CMD) $< > $@

shdoc: $(DOC_FILES) $(DOC_DIR)
