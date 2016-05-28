#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

setUp() {
	BUFFER=''
	POSTDISPLAY=''
}

tearDown() {
	restore _zsh_autosuggest_invoke_original_widget
	restore _zsh_autosuggest_suggestion
}

testModify() {
	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'BUFFER+="e"'

	stub_and_echo \
		_zsh_autosuggest_suggestion \
		'echo hello'

	_zsh_autosuggest_modify 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was not modified' \
		'e' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY does not contain suggestion' \
		'cho hello' \
		"$POSTDISPLAY"
}

testRetval() {
	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'return 1'

	_zsh_autosuggest_widget_modify 'original-widget'

	assertEquals \
		'Did not return correct value from original widget' \
		'1' \
		"$?"
}

run_tests "$0"
