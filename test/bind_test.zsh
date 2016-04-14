#!/usr/bin/env zsh

source "${0:a:h}/test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

testInvokeOriginalWidgetDefined() {
	stub_and_eval \
		zle \
		'return 1'

	_zsh_autosuggest_invoke_original_widget 'self-insert'

	assertEquals \
		'1' \
		"$?"

	assertTrue \
		'zle was not invoked' \
		'stub_called zle'

	restore zle
}

testInvokeOriginalWidgetUndefined() {
	stub_and_eval \
		zle \
		'return 1'

	_zsh_autosuggest_invoke_original_widget 'some-undefined-widget'

	assertEquals \
		'0' \
		"$?"

	assertFalse \
		'zle was invoked' \
		'stub_called zle'

	restore zle
}

run_tests "$0"
