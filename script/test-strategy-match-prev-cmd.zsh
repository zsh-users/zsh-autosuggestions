#!/usr/bin/env zsh

SCRIPT_DIR=$(dirname "$0")
TEST_DIR=$SCRIPT_DIR/../test
DIST_DIR=$SCRIPT_DIR/../

# Use stub.sh for stubbing/mocking
source $TEST_DIR/stub-1.0.2.sh

source $DIST_DIR/zsh-autosuggestions.zsh

#--------------------------------------------------------------------#
# Match Previous Command Suggestion Strategy                         #
#--------------------------------------------------------------------#

TMPHIST_FILE=/tmp/zsh-autosuggestions-test-tmp-hist

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

ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd

testNoMatchPrevIsOne() {
	stub_and_echo _zsh_autosuggest_prev_command "one"

	assertEquals \
		"Did not pick correct suggestion for prefix 'garbage' after 'one'" \
		"" \
		"$(_zsh_autosuggest_suggestion garbage)"
}

testMatchPrevIsOne() {
	stub_and_echo _zsh_autosuggest_prev_command "one"

	assertEquals \
		"Did not pick correct suggestion for prefix 'o' after 'one'" \
		"one" \
		"$(_zsh_autosuggest_suggestion o)"

	assertEquals \
		"Did not pick correct suggestion for prefix 't' after 'one'" \
		"two" \
		"$(_zsh_autosuggest_suggestion t)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'th' after 'one'" \
		"three" \
		"$(_zsh_autosuggest_suggestion th)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'f' after 'one'" \
		"five" \
		"$(_zsh_autosuggest_suggestion f)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'fo' after 'one" \
		"four" \
		"$(_zsh_autosuggest_suggestion fo)"
}

testNoMatchPrevIsTwo() {
	stub_and_echo _zsh_autosuggest_prev_command "two"

	assertEquals \
		"Did not pick correct suggestion for prefix 'garbage' after 'two'" \
		"" \
		"$(_zsh_autosuggest_suggestion garbage)"
}

testMatchPrevIsTwo() {
	stub_and_echo _zsh_autosuggest_prev_command "two"

	assertEquals \
		"Did not pick correct suggestion for prefix 'o' after 'two'" \
		"one" \
		"$(_zsh_autosuggest_suggestion o)"

	assertEquals \
		"Did not pick correct suggestion for prefix 't' after 'two'" \
		"three" \
		"$(_zsh_autosuggest_suggestion t)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'tw' after 'two'" \
		"two" \
		"$(_zsh_autosuggest_suggestion tw)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'f' after 'two'" \
		"five" \
		"$(_zsh_autosuggest_suggestion f)"

	assertEquals \
		"Did not pick correct suggestion for prefix 'fo' after 'two" \
		"four" \
		"$(_zsh_autosuggest_suggestion fo)"
}

setopt shwordsplit
SHUNIT_PARENT=$0

source $TEST_DIR/shunit2-2.1.6/src/shunit2

