#!/usr/bin/env zsh

source "${0:a:h}/test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

testEscapeCommand() {
	assertEquals \
		'Did not escape single backslash' \
		'\\' \
		"$(_zsh_autosuggest_escape_command '\')"

	assertEquals \
		'Did not escape two backslashes' \
		'\\\\' \
		"$(_zsh_autosuggest_escape_command '\\')"

	assertEquals \
		'Did not escape parentheses' \
		'\(\)' \
		"$(_zsh_autosuggest_escape_command '()')"

	assertEquals \
		'Did not escape square brackets' \
		'\[\]' \
		"$(_zsh_autosuggest_escape_command '[]')"

	assertEquals \
		'Did not escape pipe' \
		'\|' \
		"$(_zsh_autosuggest_escape_command '|')"

	assertEquals \
		'Did not escape star' \
		'\*' \
		"$(_zsh_autosuggest_escape_command '*')"

	assertEquals \
		'Did not escape question mark' \
		'\?' \
		"$(_zsh_autosuggest_escape_command '?')"
}

testPrevCommand() {
	set_history <<-'EOF'
		ls foo
		ls bar
		ls baz
	EOF

	assertEquals \
		'Did not output the last command' \
		'ls baz' \
		"$(_zsh_autosuggest_prev_command)"

	set_history <<-'EOF'
		ls foo
		ls bar
		ls baz
		ls quux
		ls foobar
	EOF

	assertEquals \
		'Did not output the last command' \
		'ls foobar' \
		"$(_zsh_autosuggest_prev_command)"
}

run_tests "$0"
