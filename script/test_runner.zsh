#!/usr/bin/env zsh

DIR="${0:a:h}"
ROOT_DIR="$DIR/.."
TEST_DIR="$ROOT_DIR/test"

header() {
	local message="$1"

	cat <<-EOF

#====================================================================#
# $message
#====================================================================#
	EOF
}

local -a tests

# Test suites to run
tests=($TEST_DIR/**/*_test.zsh)

local retval=0
for suite in $tests; do
	header "${suite#"$TEST_DIR"}"
	zsh -f "$suite" || retval=$?
done

exit retval
