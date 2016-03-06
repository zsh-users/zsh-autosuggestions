#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions

	ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
}

testNoMatch() {
	set_history <<-'EOF'
		ls foo
		ls bar
	EOF

	assertSuggestion \
		'foo' \
		''

	assertSuggestion \
		'ls q' \
		''
}

testBasicMatches() {
	set_history <<-'EOF'
		ls foo
		ls bar
	EOF

	assertSuggestion \
		'ls f' \
		'ls foo'

	assertSuggestion \
		'ls b' \
		'ls bar'
}

testMostRecentMatch() {
	set_history <<-'EOF'
		ls foo
		cd bar
		ls baz
		cd quux
	EOF

	assertSuggestion \
		'ls' \
		'ls baz'

	assertSuggestion \
		'cd' \
		'cd quux'
}

testBackslash() {
	set_history <<-'EOF'
		echo "hello\nworld"
	EOF

	assertSuggestion \
		'echo "hello\' \
		'echo "hello\nworld"'
}

testDoubleBackslash() {
	set_history <<-'EOF'
		echo "\\"
	EOF

	assertSuggestion \
		'echo "\\' \
		'echo "\\"'
}

testTilde() {
	set_history <<-'EOF'
		cd ~/something
	EOF

	assertSuggestion \
		'cd' \
		'cd ~/something'

	assertSuggestion \
		'cd ~' \
		'cd ~/something'

	assertSuggestion \
		'cd ~/s' \
		'cd ~/something'
}

testParentheses() {
	set_history <<-'EOF'
		echo "$(ls foo)"
	EOF

	assertSuggestion \
		'echo "$(' \
		'echo "$(ls foo)"'
}

testSquareBrackets() {
	set_history <<-'EOF'
		echo "$history[123]"
	EOF

	assertSuggestion \
		'echo "$history[' \
		'echo "$history[123]"'
}

testMatchMostRecentAfterPreviousCmd() {
	set_history <<-'EOF'
		echo what
		ls foo
		ls bar
		echo what
		ls baz
		ls quux
		echo what
	EOF

	assertSuggestion \
		'ls' \
		'ls baz'
}

run_tests "$0"
