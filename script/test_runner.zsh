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

# ZSH binary to use
local zsh_bin="zsh"

while getopts ":z:" opt; do
	case $opt in
		z)
			zsh_bin="$OPTARG"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument" >&2
			exit 1
			;;
	esac
done

shift $((OPTIND -1))

# Test suites to run
local -a tests
if [ $#@ -gt 0 ]; then
	tests=($@)
else
	tests=($TEST_DIR/**/*_test.zsh)
fi

local -i retval=0

for suite in $tests; do
	header "${suite#"$ROOT_DIR/"}"
	"$zsh_bin" -f "$suite" || retval=$?
done

exit $retval
