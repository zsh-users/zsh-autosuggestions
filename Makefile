DIST_DIR   := ./dist
SRC_DIR    := ./src
SCRIPT_DIR := ./script

SRC_TARGETS := \
	$(SRC_DIR)/config.zsh \
	$(SRC_DIR)/deprecated.zsh \
	$(SRC_DIR)/bind.zsh \
	$(SRC_DIR)/highlight.zsh \
	$(SRC_DIR)/widgets.zsh \
	$(SRC_DIR)/suggestion.zsh \
	$(SRC_DIR)/start.zsh

$(DIST_DIR)/autosuggestions.zsh: $(SRC_TARGETS) LICENSE
	mkdir -p $(DIST_DIR)
	cat INFO | sed -e 's/^/# /g' > $@
	echo "#" >> $@
	cat LICENSE | sed -e 's/^/# /g' >> $@
	cat >> $@ $(SRC_TARGETS)

.PHONY: clean
clean:
	rm -rf $(DIST_DIR)

.PHONY: test
test: $(DIST_DIR)/autosuggestions.zsh $(SCRIPT_DIR)/test.sh
	$(SCRIPT_DIR)/test.sh
