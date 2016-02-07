SRC_DIR    := ./src
SCRIPT_DIR := ./script

SRC_FILES := \
	$(SRC_DIR)/config.zsh \
	$(SRC_DIR)/deprecated.zsh \
	$(SRC_DIR)/bind.zsh \
	$(SRC_DIR)/highlight.zsh \
	$(SRC_DIR)/widgets.zsh \
	$(SRC_DIR)/suggestion.zsh \
	$(SRC_DIR)/start.zsh

HEADER_FILES := \
	DESCRIPTION \
	URL \
	VERSION \
	LICENSE

PLUGIN_TARGET := zsh-autosuggestions.zsh

ALL_TARGETS := \
	$(PLUGIN_TARGET)

all: $(ALL_TARGETS)

$(PLUGIN_TARGET): $(HEADER_FILES) $(SRC_FILES)
	cat $(HEADER_FILES) | sed -e 's/^/# /g' >> $@
	cat $(SRC_FILES) >> $@

.PHONY: clean
clean:
	rm $(ALL_TARGETS)

.PHONY: test
test: all
	$(SCRIPT_DIR)/test.zsh
