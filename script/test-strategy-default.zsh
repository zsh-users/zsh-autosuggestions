#!/usr/bin/env zsh

SCRIPT_DIR=$(dirname "$0")
TEST_DIR=$SCRIPT_DIR/../test
DIST_DIR=$SCRIPT_DIR/../

source $TEST_DIR/stub-1.0.2.sh

source $DIST_DIR/zsh-autosuggestions.zsh

#--------------------------------------------------------------------#
# Default Suggestions Strategy                                       #
#--------------------------------------------------------------------#

TMPHIST_FILE=/tmp/zsh-autosuggestions-test-tmp-hist

# Use stub.sh for stubbing/mocking
HISTSIZE=0  # Clear history
HISTSIZE=100

cat > $TMPHIST_FILE <<-EOH
	one
	two
	three
	four
	five
	six
	seven
	eight
	nine
	ten
	eleven
EOH
echo >> $TMPHIST_FILE

fc -R $TMPHIST_FILE

rm $TMPHIST_FILE

ZSH_AUTOSUGGEST_STRATEGY=default

testNoMatch() {
	assertEquals \
		"Did not pick correct suggestion for prefix 'garbage'" \
		"" \
		"$(_zsh_autosuggest_suggestion garbage)"
}

testMatch() {
	assertEquals \
		"Did not pick correct suggestion for prefix 'o'" \
		"one" \
		"$(_zsh_autosuggest_suggestion o)"

	assertEquals \
		"Did not pick correct suggestion for prefix 't'" \
		"ten" \
		"$(_zsh_autosuggest_suggestion t)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'tw'" \
		"two" \
		"$(_zsh_autosuggest_suggestion tw)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'f'" \
		"five" \
		"$(_zsh_autosuggest_suggestion f)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'fo'" \
		"four" \
		"$(_zsh_autosuggest_suggestion fo)"
}

setopt shwordsplit
SHUNIT_PARENT=$0

source $TEST_DIR/shunit2-2.1.6/src/shunit2

