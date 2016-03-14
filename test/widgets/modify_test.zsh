#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

testModify() {
	BUFFER=''
	POSTDISPLAY=''

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

	restore _zsh_autosuggest_invoke_original_widget
	restore _zsh_autosuggest_suggestion
}

run_tests "$0"
