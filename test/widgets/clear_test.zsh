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
}

testClear() {
	BUFFER='ec'
	POSTDISPLAY='ho hello'

	_zsh_autosuggest_clear 'original-widget'

	assertEquals \
		'BUFFER was modified' \
		'ec' \
		"$BUFFER"

	assertNull \
		'POSTDISPLAY was not cleared' \
		"$POSTDISPLAY"
}

testRetval() {
	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'return 1'

	_zsh_autosuggest_widget_clear 'original-widget'

	assertEquals \
		'Did not return correct value from original widget' \
		'1' \
		"$?"
}

testWidget() {
	stub _zsh_autosuggest_highlight_reset
	stub _zsh_autosuggest_clear
	stub _zsh_autosuggest_highlight_apply

	# Call the function pointed to by the widget since we can't call
	# the widget itself when zle is not active
	${widgets[autosuggest-clear]#*:} 'original-widget'

	assertTrue \
		'autosuggest-clear widget does not exist' \
		'zle -l autosuggest-clear'

	assertTrue \
		'highlight_reset was not called' \
		'stub_called _zsh_autosuggest_highlight_reset'

	assertTrue \
		'widget function was not called' \
		'stub_called _zsh_autosuggest_clear'

	assertTrue \
		'highlight_apply was not called' \
		'stub_called _zsh_autosuggest_highlight_apply'

	restore _zsh_autosuggest_highlight_reset
	restore _zsh_autosuggest_clear
	restore _zsh_autosuggest_highlight_apply
}

run_tests "$0"
