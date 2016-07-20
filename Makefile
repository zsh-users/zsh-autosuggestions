SRC_DIR    := ./src
VENDOR_DIR := ./vendor

SRC_FILES := \
	$(SRC_DIR)/setup.zsh \
	$(SRC_DIR)/config.zsh \
	$(SRC_DIR)/util.zsh \
	$(SRC_DIR)/deprecated.zsh \
	$(SRC_DIR)/bind.zsh \
	$(SRC_DIR)/highlight.zsh \
	$(SRC_DIR)/widgets.zsh \
	$(SRC_DIR)/strategies/*.zsh \
	$(SRC_DIR)/async.zsh \
	$(SRC_DIR)/start.zsh

HEADER_FILES := \
	DESCRIPTION \
	URL \
	VERSION \
	LICENSE

PLUGIN_TARGET := zsh-autosuggestions.zsh

SHUNIT2 := $(VENDOR_DIR)/shunit2/2.1.6
STUB_SH := $(VENDOR_DIR)/stub.sh/stub.sh

UNIT_TEST_PREREQS := \
	$(SHUNIT2) \
	$(STUB_SH)

all: $(PLUGIN_TARGET)

$(PLUGIN_TARGET): $(HEADER_FILES) $(SRC_FILES)
	cat $(HEADER_FILES) | sed -e 's/^/# /g' > $@
	cat $(SRC_FILES) >> $@

$(SHUNIT2):
	git submodule update --init vendor/shunit2

$(STUB_SH):
	git submodule update --init vendor/stub.sh

.PHONY: clean
clean:
	rm $(PLUGIN_TARGET)

.PHONY: test
test: rspec unit_test

unit_test: all $(UNIT_TEST_PREREQS)
	script/test_runner.zsh $(UNIT_TESTS)

rspec: all
	bundle exec rspec $(RSPEC_TESTS)
