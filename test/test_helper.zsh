DIR="${0:a:h}"
ROOT_DIR="$DIR/.."
VENDOR_DIR="$ROOT_DIR/vendor"

# Use stub.sh for stubbing/mocking
source "$VENDOR_DIR/stub.sh/stub.sh"

#--------------------------------------------------------------------#
# Helper Functions                                                   #
#--------------------------------------------------------------------#

# Source the autosuggestions plugin file
source_autosuggestions() {
	source "$ROOT_DIR/zsh-autosuggestions.zsh"
}

# Set history list from stdin
set_history() {
	# Make a tmp file in shunit's tmp dir
	local tmp=$(mktemp "$SHUNIT_TMPDIR/hist.XXX")

	# Write from stdin to the tmp file
	> "$tmp"

	# Write an extra line to simulate history active mode
	# See https://github.com/zsh-users/zsh/blob/ca3bc0d95d7deab4f5381f12b15047de748c0814/Src/hist.c#L69-L82
	echo >> "$tmp"

	# Clear history and re-read from the tmp file
	fc -P; fc -p; fc -R "$tmp"

	rm "$tmp"
}

# Should be called at the bottom of every test suite file
# Pass in the name of the test script ($0) for shunit
run_tests() {
	local test_script="$1"
	shift

	# Required for shunit to work with zsh
	setopt localoptions shwordsplit
	SHUNIT_PARENT="$test_script"

	source "$VENDOR_DIR/shunit2/2.1.6/src/shunit2"
}

#--------------------------------------------------------------------#
# Custom Assertions                                                  #
#--------------------------------------------------------------------#

assertSuggestion() {
	local prefix="$1"
	local expected_suggestion="$2"

	assertEquals \
		"Did not get correct suggestion for prefix:<$prefix> using strategy <$ZSH_AUTOSUGGEST_STRATEGY>" \
		"$expected_suggestion" \
		"$(_zsh_autosuggest_suggestion "$prefix")"
}
