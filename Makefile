SRC_DIR    := ./src
TEST_DIR   := ./script
VENDOR_DIR := ./vendor

SRC_FILES := \
	$(SRC_DIR)/config.zsh \
	$(SRC_DIR)/deprecated.zsh \
	$(SRC_DIR)/bind.zsh \
	$(SRC_DIR)/highlight.zsh \
	$(SRC_DIR)/widgets.zsh \
	$(SRC_DIR)/suggestion.zsh \
	$(SRC_DIR)/strategies/*.zsh \
	$(SRC_DIR)/start.zsh

HEADER_FILES := \
	DESCRIPTION \
	URL \
	VERSION \
	LICENSE

PLUGIN_TARGET := zsh-autosuggestions.zsh
OH_MY_ZSH_LINK_TARGET := zsh-autosuggestions.plugin.zsh

ALL_TARGETS := \
	$(PLUGIN_TARGET) \
	$(OH_MY_ZSH_LINK_TARGET)

SHUNIT2 := $(VENDOR_DIR)/shunit2/2.1.6
STUB_SH := $(VENDOR_DIR)/stub.sh/stub.sh

TEST_PREREQS := \
	$(SHUNIT2) \
	$(STUB_SH)

TEST_FILES := \
	$(TEST_DIR)/**/*.zsh

all: $(ALL_TARGETS)

$(PLUGIN_TARGET): $(HEADER_FILES) $(SRC_FILES)
	cat $(HEADER_FILES) | sed -e 's/^/# /g' > $@
	cat $(SRC_FILES) >> $@

$(OH_MY_ZSH_LINK_TARGET): $(PLUGIN_TARGET)
	ln -s $(PLUGIN_TARGET) $@

$(SHUNIT2):
	git submodule update --init vendor/shunit2

$(STUB_SH):
	git submodule update --init vendor/stub.sh

.PHONY: clean
clean:
	rm $(ALL_TARGETS)

.PHONY: test
test: all $(TEST_PREREQS)
	script/test_runner.zsh
