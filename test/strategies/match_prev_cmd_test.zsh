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
