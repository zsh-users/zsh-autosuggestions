#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

tearDown() {
	restore _zsh_autosuggest_invoke_original_widget
}

testRetval() {
	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'return 1'

	_zsh_autosuggest_widget_execute 'original-widget'

	assertEquals \
		'Did not return correct value from original widget' \
		'1' \
		"$?"
}

run_tests "$0"
